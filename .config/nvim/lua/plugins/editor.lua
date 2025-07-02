return {
  -- todo-comments.nvim
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      {
        "]t",
        function()
          return require("todo-comments").jump_next()
        end,
        desc = "Jump to next todo comment",
      },
      {
        "[t",
        function()
          return require("todo-comments").jump_prev()
        end,
        desc = "Jump to previous todo comment",
      },
    },
  },

  -- nvim-autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_filetype = { "snacks_picker_input", "text" },
      disable_in_macro = false,
      check_ts = true,
    },
  },

  -- trouble.nvim
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = { use_diagnostic_signs = true, focus = true },
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Toggle trouble.nvim",
      },
      {
        "<leader>xw",
        "<cmd>Trouble diagnostics<cr>",
        desc = "Open workspace diagnostics",
      },
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Open document diagnostics",
      },
      { "gR", "<cmd>Trouble lsp toggle<cr>", desc = "References" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Todo (Trouble)" },
      {
        "<leader>xT",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>",
        desc = "Todo/Fix/Fixme (Trouble)",
      },
    },
  },

  -- vim-cool
  { "romainl/vim-cool", keys = { "/", "?", "*", "#", "g*", "g#", "n", "N" } },
  -- HACK: There doesn't seem to be an autocommand event to detect when you start
  -- searching, so this will have to do until I can find an event for that or until neovim creates that event
  -- Related: https://github.com/neovim/neovim/issues/18879

  -- neo-tree.nvim
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker", -- for open_with_window_picker keymaps
        version = "2.*",
        config = function()
          require("window-picker").setup({
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { "neo-tree", "neo-tree-popup", "notify" },
                -- if the buffer type is one of following, the window will be ignored
                buftype = { "terminal", "quickfix" },
              },
            },
          })
        end,
      },
    },
    -- Load neo-tree.nvim if we provide a directory as an argument
    init = function()
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup(
          "Neotree_start_directory",
          { clear = true }
        ),
        desc = "Start neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            ---@diagnostic disable-next-line: param-type-mismatch
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("lazy").load({ plugins = { "neo-tree.nvim" } })
            end
          end
        end,
      })
    end,
    branch = "v3.x",
    keys = {
      {
        "<leader>e",
        function()
          return require("neo-tree.command").execute({
            toggle = true,
            dir = vim.uv.cwd(),
          })
        end,
        desc = "Open neo-tree.nvim",
      },
      {
        "<leader>ge",
        function()
          return require("neo-tree.command").execute({
            source = "git_status",
            toggle = true,
          })
        end,
        desc = "Git explorer",
      },
      {
        "<leader>be",
        function()
          return require("neo-tree.command").execute({
            source = "buffers",
            toggle = true,
          })
        end,
        desc = "Buffer explorer",
      },
    },
    cmd = "Neotree",
    opts = {
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            -- auto close
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
        {
          event = "file_moved",
          handler = function(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
          end,
        },
        {
          event = "file_renamed",
          handler = function(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
          end,
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git" },
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
      },
      window = {
        position = "right",
        mappings = {
          ["<space>"] = "none",
          ["h"] = {
            function(state)
              local node = state.tree:get_node()
              if node.type == "directory" and node:is_expanded() then
                require("neo-tree.sources.filesystem").toggle_directory(
                  state,
                  node
                )
              else
                require("neo-tree.ui.renderer").focus_node(
                  state,
                  node:get_parent_id()
                )
              end
            end,
            desc = "Open directory",
          },
          ["l"] = {
            function(state)
              local node = state.tree:get_node()
              if node.type == "directory" then
                if not node:is_expanded() then
                  require("neo-tree.sources.filesystem").toggle_directory(
                    state,
                    node
                  )
                elseif node:has_children() then
                  require("neo-tree.ui.renderer").focus_node(
                    state,
                    node:get_child_ids()[1]
                  )
                end
              end
            end,
            desc = "Close directory",
          },
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy path to clipboard",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
    },
  },

  -- leap.nvim
  {
    "ggandor/leap.nvim",
    dependencies = { "tpope/vim-repeat", keys = { "." } },
    keys = {
      {
        "s",
        "<Plug>(leap-forward)",
        mode = { "n", "x", "o" },
        desc = "Leap forward",
      },
      {
        "S",
        "<Plug>(leap-backward)",
        mode = { "n", "x", "o" },
        desc = "Leap backward",
      },
      {
        "gs",
        "<Plug>(leap-from-window)",
        mode = { "n", "x", "o" },
        desc = "Leap from windows",
      },
    },
    opts = {
      -- Disable auto-jumping to first match
      safe_labels = {},

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group:
      equivalence_classes = {
        " \t\r\n",
        "([{",
        "}])",
        "\"'`",
      },
      -- Define a preview filter (skip the middle of alphanumeric words):
      preview_filter = function(ch0, ch1, ch2)
        return not (
          ch1:match("%s")
          or ch0:match("%w") and ch1:match("%w") and ch2:match("%w")
        )
      end,
    },
  },

  -- flit.nvim
  {
    "ggandor/flit.nvim",
    dependencies = "ggandor/leap.nvim",
    opts = { labeled_modes = "nx" },
    keys = function()
      local ret = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
  },

  -- quick-scope
  -- {
  --   "unblevable/quick-scope",
  --   keys = { "f", "F", "t", "T" },
  --   init = function()
  --     vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
  --     vim.g.qs_lazy_highlight = 1
  --     vim.g.qs_max_chars = 150
  --     vim.cmd([[
  --       augroup qs_colors
  --         autocmd!
  --         autocmd ColorScheme * highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline
  --         autocmd ColorScheme * highlight QuickScopeSecondary guifg='#eF5F70' gui=underline ctermfg=81 cterm=underline
  --       augroup END
  --     ]])
  --   end
  -- },

  -- gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd("BufRead", {
        group = vim.api.nvim_create_augroup(
          "GitSignsLazyLoad",
          { clear = true }
        ),
        callback = function()
          vim.fn.system(
            "git -C " .. '"' .. vim.fn.expand("%:p:h") .. '"' .. " rev-parse"
          )
          if vim.v.shell_error == 0 then
            vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
            vim.schedule(function()
              require("lazy").load({ plugins = { "gitsigns.nvim" } })
            end)
          end
        end,
      })
    end,
    cmd = "Gitsigns",
    ft = "gitcommit",
    keys = {
      { "<leader>gB", "<cmd>Gitsigns blame_line<CR>", desc = "Open git blame" },
      {
        "<leader>gp",
        "<cmd>Gitsigns preview_hunk_inline<CR>",
        desc = "Preview the hunk",
      },
      {
        "<leader>gr",
        "<cmd>Gitsigns reset_hunk<CR>",
        mode = { "n", "v" },
        desc = "Reset the hunk",
      },
      {
        "<leader>gR",
        "<cmd>Gitsigns reset_buffer<CR>",
        desc = "Reset the buffer",
      },
      {
        "<leader>gs",
        "<cmd>Gitsigns stage_hunk<CR>",
        mode = { "n", "v" },
        desc = "Stage the hunk",
      },
      {
        "<leader>gS",
        "<cmd>Gitsigns stage_buffer<CR>",
        desc = "Stage the buffer",
      },
      { "<leader>gd", "<cmd>Gitsigns diffthis<CR>", desc = "Open a diff" },
      {
        "<leader>gq",
        "<cmd>Gitsigns setqflist<CR>",
        desc = "Open quickfix list with hunks",
      },
      {
        "<leader>gl",
        "<cmd>Gitsigns setloclist<CR>",
        desc = "Open location list with hunks",
      },
      {
        "<leader>gL",
        "<cmd>Gitsigns toggle_current_line_blame<CR>",
        desc = "Toggle line blame",
      },
      {
        "]g",
        function()
          return require("gitsigns").nav_hunk("next", { wrap = false })
        end,
        desc = "Next hunk",
      },
      {
        "[g",
        function()
          return require("gitsigns").nav_hunk("prev", { wrap = false })
        end,
        desc = "Previous hunk",
      },
    },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
      },
      attach_to_untracked = true,
      numhl = true,
      -- word_diff = true,
    },
  },

  -- toggleterm.nvim
  {
    "akinsho/toggleterm.nvim",
    -- version = "*",
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(
            term.bufnr,
            "n",
            "q",
            "close",
            { noremap = true, silent = true }
          )
        end,
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
      })
      function _lazygit_toggle()
        lazygit:toggle()
      end
      local ret = {
        {
          "<leader>tv",
          "<cmd>TermNew direction=vertical<CR>",
          desc = "Open a vertical terminal",
        },
        {
          "<leader>th",
          "<cmd>TermNew direction=horizontal<CR>",
          desc = "Open a horizontal terminal",
        },
        {
          "<leader>tf",
          "<cmd>ToggleTerm direction=float<CR>",
          desc = "Open a floating terminal",
        },
        {
          "<leader>'",
          "<cmd>lua _lazygit_toggle()<CR>",
          desc = "Open a floating terminal",
          noremap = true,
          silent = true,
        },
      }
      return ret
    end,
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.ceil(vim.o.columns * 0.4)
        else
          return 20
        end
      end,
      hide_numbers = true,
      shell = vim.o.shell,
      shade_terminals = true,
      shading_factor = 2,
      persist_size = true,
      start_in_insert = false,
      direction = "float",
      close_on_exit = true,
      float_opts = { border = "curved" },
    },
  },

  -- snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = false,
        preset = {
          pick = "nil",
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = "",
              key = "e",
              desc = "New file",
              action = ":ene | startinsert",
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent Files",
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = " ",
              key = "g",
              desc = "Find Text",
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            {
              icon = "",
              key = "c",
              desc = "Configuration",
              action = ":cd ~/.config/nvim | e ~/.config/nvim/init.lua",
            },
            {
              icon = "",
              key = "u",
              desc = "Update plugins",
              action = ":Lazy update",
            },
            { icon = "", key = "m", desc = "Mason", action = ":Mason" },
            {
              icon = "󰦛",
              key = "l",
              desc = "Restore last session",
              action = ":lua require('persistence').load({ last = true })",
            },
            { icon = "", key = "q", desc = "Quit Neovim", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      explorer = { enabled = false },
      image = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            -- your explorer picker configuration comes here
            -- or leave it empty to use the default settings
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = {
        animate = {
          duration = {
            total = 150,
          },
        },
      },
      statuscolumn = {
        enabled = false,
        left = { "fold", "git" },
        right = { "mark", "sign" },
        folds = {
          open = true,
          git_hl = false,
        },
        git = {
          patterns = { "GitSign" },
        },
      },
      words = {
        enabled = true,
        debounce = 100,
      },
    },
    keys = {
      -- Top Pickers & Explorer
      {
        "<leader><space>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart Find Files",
      },
      {
        "<leader>,",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>n",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification History",
      },
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "File Explorer",
      },
      -- find
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent",
      },
      -- git
      {
        "<leader>gb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git Branches",
      },
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gL",
        function()
          Snacks.picker.git_log_line()
        end,
        desc = "Git Log Line",
      },
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git Status",
      },
      {
        "<leader>gS",
        function()
          Snacks.picker.git_stash()
        end,
        desc = "Git Stash",
      },
      {
        "<leader>gd",
        function()
          Snacks.picker.git_diff()
        end,
        desc = "Git Diff (Hunks)",
      },
      {
        "<leader>gf",
        function()
          Snacks.picker.git_log_file()
        end,
        desc = "Git Log File",
      },
      -- Grep
      {
        "<leader>sb",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sB",
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.grep_word()
        end,
        desc = "Visual selection or word",
        mode = { "n", "x" },
      },
      -- search
      {
        '<leader>s"',
        function()
          Snacks.picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>s/",
        function()
          Snacks.picker.search_history()
        end,
        desc = "Search History",
      },
      {
        "<leader>sa",
        function()
          Snacks.picker.autocmds()
        end,
        desc = "Autocmds",
      },
      {
        "<leader>sb",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sc",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sD",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          Snacks.picker.highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>si",
        function()
          Snacks.picker.icons()
        end,
        desc = "Icons",
      },
      {
        "<leader>sj",
        function()
          Snacks.picker.jumps()
        end,
        desc = "Jumps",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          Snacks.picker.loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sm",
        function()
          Snacks.picker.marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>sM",
        function()
          Snacks.picker.man()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sp",
        function()
          Snacks.picker.lazy()
        end,
        desc = "Search for Plugin Spec",
      },
      {
        "<leader>sq",
        function()
          Snacks.picker.qflist()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>sR",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>su",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo History",
      },
      {
        "<leader>uC",
        function()
          Snacks.picker.colorschemes()
        end,
        desc = "Colorschemes",
      },
      -- LSP
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = "Goto Definition",
      },
      {
        "gD",
        function()
          Snacks.picker.lsp_declarations()
        end,
        desc = "Goto Declaration",
      },
      {
        "gr",
        function()
          Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = "References",
      },
      {
        "gi",
        function()
          Snacks.picker.lsp_implementations()
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          Snacks.picker.lsp_type_definitions()
        end,
        desc = "Goto T[y]pe Definition",
      },
      {
        "<leader>ss",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Symbols",
      },
      {
        "<leader>sS",
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
      -- Other
      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
      {
        "<leader>Z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File",
      },
      {
        "<leader>gB",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Browse",
        mode = { "n", "v" },
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle Terminal",
      },
      {
        "<c-_>",
        function()
          Snacks.terminal()
        end,
        desc = "which_key_ignore",
      },
      {
        "]]",
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = { "n", "t" },
      },
      {
        "[[",
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = { "n", "t" },
      },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          })
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle
            .option("relativenumber", { name = "Relative Number" })
            :map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", {
              off = 0,
              on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
            })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle
            .option(
              "background",
              { off = "light", on = "dark", name = "Dark Background" }
            )
            :map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },

  -- highlight-undo.nvim
  {
    "tzachar/highlight-undo.nvim",
    keys = { "u", "<C-r>" },
    config = true,
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Open undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_ShortIndicators = 1
    end,
  },

  -- better-escape.nvim
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      i = {
        j = {
          j = false,
        },
      },
      c = {
        j = {
          j = false,
        },
      },
      t = {
        j = {
          j = false,
        },
      },
    },
  },

  -- nvim-gomove
  {
    "booperlv/nvim-gomove",
    config = true,
    keys = {
      { "<C-h>", mode = { "n", "v" }, desc = "Block left" },
      { "<C-j>", mode = { "n", "v" }, desc = "Block down" },
      { "<C-k>", mode = { "n", "v" }, desc = "Block up" },
      { "<C-l>", mode = { "n", "v" }, desc = "Block right" },
    },
  },

  -- persistence.nvim
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = true,
    keys = {
      {
        "<leader>qs",
        function()
          return require("persistence").load()
        end,
        desc = "Restore the session for the current dir",
      },
      {
        "<leader>ql",
        function()
          return require("persistence").load({ last = true })
        end,
        desc = "Restore the last session",
      },
      {
        "<leader>qS",
        function()
          return require("persistence").select()
        end,
        desc = "Select session",
      },
      {
        "<leader>qd",
        function()
          return require("persistence").stop()
        end,
        desc = "Stop persistence",
      },
    },
  },

  -- mini.surround
  {
    "echasnovski/mini.surround",
    keys = {
      { "gza", mode = { "n", "v" }, desc = "Add surrounding" },
      { "gzd", desc = "Delete surrounding" },
      { "gzf", desc = "Find right surrounding" },
      { "gzF", desc = "Find left surrounding" },
      { "gzh", desc = "Highlight surrounding" },
      { "gzr", desc = "Replace surrounding" },
      { "gzn", desc = "Updated n_lines" },
    },
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        replace = "gzr",
        update_n_lines = "gzn",
      },
    },
  },

  -- precognition.nvim
  {
    "tris203/precognition.nvim",
    keys = {
      {
        "<leader>pP",
        "<cmd>Precognition toggle<CR>",
        desc = "Toggle precognition.nvim",
      },
      {
        "<leader>pp",
        "<cmd>Precognition peek<CR>",
        desc = "Peek precognition.nvim",
      },
    },
    opts = { startVisible = false },
  },

  -- in-and-out.nvim
  {
    "ysmb-wtsg/in-and-out.nvim",
    keys = {
      {
        "<C-CR>",
        function()
          return require("in-and-out").in_and_out()
        end,
        mode = "i",
      },
    },
  },

  -- vim-kitty
  { "fladson/vim-kitty", ft = "kitty" },

  {
    "jamessan/vim-gnupg",
    event = "BufAdd *.gpg",
  },

  { "RaafatTurki/hex.nvim", ft = "xxd" },

  { "diepm/vim-rest-console", ft = "rest" },

  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app & yarn install",
  },

  {
    "sotte/presenting.vim",
    ft = "markdown",
    init = function()
      --[[ vim.g.markdown_fenced_languages = ["vim", "json", "bash", "python", "html", "javascript", "typescript"] ]]
      vim.g.presenting_figlets = 1
      vim.g.presenting_figlets = 1
      vim.g.presenting_top_margin = 2
      vim.b.presenting_slide_separator = "\v(^|\n)\ze#{2} "

      vim.cmd([[
        augroup presentation
            autocmd!
        " Presentation mode
            au Filetype markdown nnoremap <buffer> <F10> :PresentingStart<CR>
        " ASCII art
            au Filetype markdown nnoremap <buffer> <F12> :.!toilet -w 200 -f term -F border<CR>
        augroup end
      ]])
    end,
  },
}
