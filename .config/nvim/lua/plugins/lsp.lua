return {
  -- mason.nvim
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "",
          package_pending = "",
          package_uninstalled = "",
        },
      },
      log_level = vim.log.levels.OFF,
    },
  },

  -- mason-tool-installer.nvim
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = "williamboman/mason.nvim",
    --[[ cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    }, ]]
    opts = {
      ensure_installed = {
        -- Language serverss
        "lua-language-server",
        -- "clangd",
        "marksman",
        "bash-language-server",
        "taplo",
        --[[ "html-lsp",
        "eslint-lsp",
        "typescript-language-server",
        "css-lsp", ]]
        -- Linters and formatters
        "stylua",
        "markdownlint",
        "selene",
        --[[ "shellcheck",
        "clang-format",
        "cpplint", ]]
        "shfmt",
        -- "markuplint",
        "prettierd",
        -- "stylelint",
        "codespell",
        -- Debuggers
        --[[ "codelldb",
        "bash-debug-adapter",
        "firefox-debug-adapter", ]]
      },
      run_on_start = true,
    },
  },

  -- nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "Saghen/blink.cmp",
      "williamboman/mason-lspconfig.nvim",
    },
    keys = {
      { "<leader>rn", vim.lsp.buf.rename, desc = "Reanem symbol" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ---@type vim.diagnostic.Opts
      diagnostics = {
        jump = { float = true },
        virtual_text = false,
        virtual_lines = false,
        severity_sort = true,
      },
      servers = {
        ccls = {},
        lua_ls = {
          log_level = 0,
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              completion = { callSnippet = "Replace" },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                arrrayIndex = "Disable",
              },
            },
          },
        },
        marksman = {},
        bashls = { filetypes = { "sh", "zsh", "bash" } },
        taplo = {},
        --[[ html = {},
        eslint = {},
        ts_ls = {
          init_options = {
            preferences = {
              disableSuggestions = true,
            },
          },
        },
        cssls = {}, ]]
      },
    },
    config = function(_, opts)
      for server, config in pairs(opts.servers) do
        config.capabilities =
          require("blink.cmp").get_lsp_capabilities(config.capabilities)
        vim.lsp.enable(server)
        vim.lsp.config(server, config)
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
      require("mason-lspconfig").setup({
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server)
            local config = opts.servers[server] or {}
            config.capabilities = require("blink.cmp").get_lsp_capabilities(
              config.capabilities or {}
            )
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            vim.lsp.enable(server)
            vim.lsp.config(server, config)
          end,
        },
      })
    end,
  },

  -- lazydev.nvim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        "lazy.nvim",
        "nvim-dap-ui",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  -- luvit-meta
  { "Bilal2453/luvit-meta", lazy = true },

  -- conform.nvim
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
        markdown = { "prettierd" },
        --[[ html = { "prettierd" },
        javascript = { "prettierd" },
        css = { "prettierd" }, ]]
        json = { "prettierd" },
        toml = { "taplo" },
        go = { "golines" },
        cpp = { "clang-format" },
        c = { "clang-format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        ["*"] = {
          "trim_whitespace",
          "squeeze_blanks",
        },
        -- ["_"] = {},
      },
      -- Default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          lsp_format = "fallback",
          timeout_ms = 500,
        }
      end,
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2", "-ci", "-bn" },
        },
        --[[ clang_format = {
          prepend_args = { "--style=Google" },
        }, ]]
      },
    },
  },

  -- nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = "BufWritePost",
    config = function()
      local lint = require("lint")
      lint.linters.revive.args = {
        "-formatter",
        "json",
        "-config",
        "./revive.toml",
      }
      lint.linters_by_ft = {
        lua = { "luac", "selene" },
        bash = {
          "bash",
          -- "shellcheck",
        },
        zsh = { "zsh" },
        markdown = { "markdownlint" },
        go = { "revive" },
        --[[ html = { "markuplint" },
        css = { "stylelint" },
        cpp = { "cpplint" },
        c = { "cpplint" }, ]]
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          -- Attempt to lint the document
          lint.try_lint()

          -- Use codespell on all filetypes
          lint.try_lint("codespell")
        end,
      })
    end,
  },

  -- nvim-navic
  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    opts = {
      highlight = true,
      lsp = { auto_attach = true },
      lazy_update_context = true,
      icons = {
        Array = " ",
        Boolean = " ",
        Class = " ",
        Color = " ",
        Constant = " ",
        Constructor = " ",
        Copilot = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Namespace = " ",
        Null = " ",
        Number = " ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        String = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
    },
  },

  -- fidget.nvim
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = { window = { winblend = 0 } },
      logger = { level = vim.log.levels.OFF },
      progress = { suppress_on_insert = true, display = { render_limit = 3 } },
    },
  },

  -- actions-preview.nvim
  {
    "aznhe21/actions-preview.nvim",
    opts = function()
      local hl = require("actions-preview.highlight")
      return {
        backend = { "snacks", "telescope", "minipick", "nui" },
        snacks = {
          layout = { preset = "default" },
        },
        highlight_command = { hl.delta("delta --side-by-side") },
      }
    end,
    keys = {
      {
        "<M-CR>",
        function()
          return require("actions-preview").code_actions()
        end,
        mode = { "n", "v" },
        desc = "Open actions-preview.nvim",
      },
    },
  },

  -- nvim-lightbulb
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
      autocmd = {
        enabled = true,
      },
    },
  },
}
