local status_ok, dap = pcall(require, "dap")
if not status_ok then
  return
end

dap.defaults.fallback.auto_continue_if_many_stopped = false

local repl = require 'dap.repl'
repl.commands = vim.tbl_extend('force', repl.commands, {
  -- Add a new alias for the existing .exit command
  exit = { 'exit', '.exit', '.bye' },
  -- Add your own commands; run `.echo hello world` to invoke
  -- this function with the text "hello world"
  custom_commands = {
    ['.read'] = function(text)
      dap.repl.append(text)
      local args = {}
      for w in string.gmatch(text, "([^%s]+)") do
        table.insert(args, w)
      end
      local session = dap.session()
      session:request('readMemory', { memoryReference = args[1], count = tonumber(args[2]) }, function(err, response)
        if not response then
          return
        end
        dap.repl.append(response.data)
      end)
    end,
    ['.var'] = function(text)
      dap.repl.append(text)
      local args = {}
      for w in string.gmatch(text, "([^%s]+)") do
        table.insert(args, w)
      end
      local session = dap.session()
      session:request('variables', { variablesReference = tonumber(args[1]), count = tonumber(args[2]) },
        function(err, response)
          if not response then
            return
          end
          dap.repl.append(response.data)
        end)
    end,
  },
})

local remap = vim.api.nvim_set_keymap
remap("n", "<F5>", ":lua require'dap'.continue()<CR>", { noremap = false, silent = false })
remap("n", "<F9>", ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = false, silent = false })
remap("n", "<F10>", ":lua require'dap'.step_over()<CR>", { noremap = false, silent = false })
remap("n", "<F11>", ":lua require'dap'.step_into()<CR>", { noremap = false, silent = false })
remap("n", "<F12>", ":lua require'dap'.step_out()<CR>", { noremap = false, silent = false })
remap("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", { noremap = false, silent = false })
remap("n", "<leader>dl", ":lua require'dap'.run_last()<CR>", { noremap = false, silent = false })

local dapui = require("dapui")
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7"),
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position.
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 10,
      position = "bottom",
    },
  },
  floating = {
    max_height = nil,   -- These can be integers or a float between 0 and 1.
    max_width = nil,    -- Floats will be treated as percentage of your screen.
    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

local path = require "mason-core.path"

dap.adapters.delve = function(cb, config)
  if config.request == 'attach' and config.mode == 'remote' then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a dlv `remote attach` configuration'),
      host = assert(host, '`connect.host` is required for a dlv `remote attach` configuration'),
    })
  else
    cb({
      type = 'server',
      port = '${port}',
      executable = {
        command = path.concat { vim.fn.stdpath("data"), "mason", "bin", "dlv" },
        args = { 'dap', '-l', '127.0.0.1:${port}' },
      },
    })
  end
end

-- Start on remote: dlv --listen=:2345 --headless=true --log=true --api-version=2 exec ./main

dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = path.concat { vim.fn.stdpath("data"), "mason", "bin", "OpenDebugAD7" },
}

dap.configurations.go = {
  {
    type = 'delve',
    name = 'Execute',
    request = 'launch',
    showLog = false,
    program = '${file}',
  },
  {
    type = 'delve',
    name = 'Debug test', -- configuration for debugging test files
    request = 'launch',
    mode = 'test',
    program = '${file}'
  },
  -- works with go.mod packages and sub packages
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  },
  {
    type = 'delve',
    name = 'Remote',
    request = 'attach',
    mode = 'remote',
    connect = {
      port = 2345,
      host = function()
        return vim.fn.input('Remote host: ', 'localhost')
      end,
    },
    showLog = true,
    trace = 'log',
    logOutput = 'rpc',
  }
}

--[[ dap.configurations.cpp = { ]]
--[[   { ]]
--[[     name = "Launch file vscode-cpptools", ]]
--[[     type = "cppdbg", ]]
--[[     request = "launch", ]]
--[[     program = function() ]]
--[[       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') ]]
--[[     end, ]]
--[[     cwd = '${workspaceFolder}', ]]
--[[     MIMode = 'gdb', ]]
--[[     setupCommands = { ]]
--[[       { ]]
--[[         text = '-enable-pretty-printing', ]]
--[[         description = 'enable pretty printing', ]]
--[[         ignoreFailures = false ]]
--[[       }, ]]
--[[     }, ]]
--[[   }, ]]
--[[   { ]]
--[[     name = 'Attach to gdbserver', ]]
--[[     type = 'cppdbg', ]]
--[[     request = 'launch', ]]
--[[     program = function() ]]
--[[       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') ]]
--[[     end, ]]
--[[     miDebuggerServerAddress = function() ]]
--[[       return vim.fn.input('Remote url: ', 'localhost:1234') ]]
--[[     end, ]]
--[[     cwd = '${workspaceFolder}', ]]
--[[     miDebuggerPath = '/usr/bin/gdb-multiarch', ]]
--[[     MIMode = 'gdb', ]]
--[[     setupCommands = { ]]
--[[       { ]]
--[[         text = '-enable-pretty-printing', ]]
--[[         description = 'enable pretty printing', ]]
--[[         ignoreFailures = false ]]
--[[       }, ]]
--[[     }, ]]
--[[   }, ]]
--[[ } ]]
--[[]]
--[[ dap.configurations.c = dap.configurations.cpp ]]
--[[ dap.configurations.rust = dap.configurations.cpp ]]
require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'c', 'cpp', 'rust' }, delve = { 'go' } })
