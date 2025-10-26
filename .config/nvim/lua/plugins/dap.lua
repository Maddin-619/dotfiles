-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      -- Creates a beautiful debugger UI
      "rcarriga/nvim-dap-ui",
      dependencies = "nvim-neotest/nvim-nio",
      keys = {
        {
          "<leader>du",
          function()
            return require("dapui").toggle()
          end,
          desc = "Dap UI",
        },
        {
          "<leader>de",
          function()
            return require("dapui").eval()
          end,
          desc = "Eval",
          mode = { "n", "v" },
        },
      },
      opts = {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      },
      init = function()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup()
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end,
    },
    -- Installs the debug adapters for you
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = {
        "williamboman/mason.nvim",
      },
    },
    -- Add your own debuggers here
    "leoluz/nvim-dap-go",
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debug: Start/Continue",
    },
    {
      "<F1>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: Step Into",
    },
    {
      "<F2>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: Step Over",
    },
    {
      "<F3>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: Step Out",
    },
    {
      "<leader>b",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: Toggle Breakpoint",
    },
    {
      "<leader>B",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Debug: Set Breakpoint",
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      "<F7>",
      function()
        require("dapui").toggle()
      end,
      desc = "Debug: See last session result.",
    },
  },
  config = function()
    local dap = require("dap")
    if not dap.adapters then
      dap.adapters = {}
    end
    dap.adapters["probe-rs-debug"] = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.expand("$HOME/.cargo/bin/probe-rs"),
        args = { "dap-server", "--port", "${port}" },
      },
    }

    require("mason-nvim-dap").setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        "delve",
        "cpptools",
      },
    })

    -- Set up of handlers for RTT and probe-rs messages.
    -- In addition to nvim-dap-ui I write messages to a probe-rs.log in project folder
    -- If RTT is enabled, probe-rs sends an event after init of a channel. This has to be confirmed or otherwise probe-rs wont sent the rtt data.
    dap.listeners.before["event_probe-rs-rtt-channel-config"]["plugins.nvim-dap-probe-rs"] = function(
      session,
      body
    )
      local utils = require("dap.utils")
      utils.notify(
        string.format(
          'probe-rs: Opening RTT channel %d with name "%s"!',
          body.channelNumber,
          body.channelName
        )
      )
      local file = io.open("probe-rs.log", "a")
      if file then
        file:write(
          string.format(
            '%s: Opening RTT channel %d with name "%s"!\n',
            os.date("%Y-%m-%d-T%H:%M:%S"),
            body.channelNumber,
            body.channelName
          )
        )
      end
      if file then
        file:close()
      end
      session:request("rttWindowOpened", { body.channelNumber, true })
    end
    -- After confirming RTT window is open, we will get rtt-data-events.
    -- I print them to the dap-repl, which is one way and not separated.
    -- If you have better ideas, let me know.
    dap.listeners.before["event_probe-rs-rtt-data"]["plugins.nvim-dap-probe-rs"] = function(
      _,
      body
    )
      local message = string.format(
        "%s: RTT-Channel %d - Message: %s",
        os.date("%Y-%m-%d-T%H:%M:%S"),
        body.channelNumber,
        body.data
      )
      local repl = require("dap.repl")
      repl.append(message)
      local file = io.open("probe-rs.log", "a")
      if file then
        file:write(message)
      end
      if file then
        file:close()
      end
    end
    -- Probe-rs can send messages, which are handled with this listener.
    dap.listeners.before["event_probe-rs-show-message"]["plugins.nvim-dap-probe-rs"] = function(
      _,
      body
    )
      local message = string.format(
        "%s: probe-rs message: %s",
        os.date("%Y-%m-%d-T%H:%M:%S"),
        body.message
      )
      local repl = require("dap.repl")
      repl.append(message)
      local file = io.open("probe-rs.log", "a")
      if file then
        file:write(message)
      end
      if file then
        file:close()
      end
    end

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    local repl = require("dap.repl")
    repl.commands = vim.tbl_extend("force", repl.commands, {
      -- Add a new alias for the existing .exit command
      exit = { "exit", ".exit", ".bye" },
      -- Add your own commands; run `.echo hello world` to invoke
      -- this function with the text "hello world"
      custom_commands = {
        [".read"] = function(text)
          dap.repl.append(text)
          local args = {}
          for w in string.gmatch(text, "([^%s]+)") do
            table.insert(args, w)
          end
          local session = dap.session()
          session:request(
            "readMemory",
            { memoryReference = args[1], count = tonumber(args[2]) },
            function(err, response)
              if not response then
                return
              end
              dap.repl.append(response.data)
            end
          )
        end,
        [".var"] = function(text)
          dap.repl.append(text)
          local args = {}
          for w in string.gmatch(text, "([^%s]+)") do
            table.insert(args, w)
          end
          local session = dap.session()
          session:request("variables", {
            variablesReference = tonumber(args[1]),
            count = tonumber(args[2]),
          }, function(err, response)
            if not response then
              return
            end
            dap.repl.append(response.data)
          end)
        end,
      },
    })

    -- Install golang specific config
    require("dap-go").setup({
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has("win32") == 0,
      },
    })
  end,
}
