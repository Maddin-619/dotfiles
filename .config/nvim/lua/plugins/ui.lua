return {
  -- -- tokyonight.nvim
  -- {
  -- 	"folke/tokyonight.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	opts = {
  -- 		style = "night",
  -- 		transparent = true,
  -- 		lualine_bold = true,
  -- 		terminal_colors = true,
  -- 		on_highlights = function(hl, c)
  -- 			local prompt = "#2d3149"
  -- 			hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
  -- 			hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
  -- 			hl.TelescopePromptNormal = { bg = prompt }
  -- 			hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
  -- 			hl.TelescopePromptTitle = { bg = prompt, fg = prompt }
  -- 			hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
  -- 			hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
  -- 		end,
  -- 	},
  -- 	config = function(_, opts)
  -- 		local tokyonight = require("tokyonight")
  -- 		tokyonight.setup(opts)
  -- 		tokyonight.load()
  -- 	end,
  -- },

  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Alternatively set style in setup
      -- style = 'light'
      -- Enable transparent background
      transparent = true,
      -- Enable italic comment
      italic_comments = true,
      -- Underline `@markup.link.*` variants
      underline_links = true,
      -- Disable nvim-tree background color
      disable_nvimtree_bg = true,
      -- Apply theme colors to terminal
      terminal_colors = true,
      -- Override colors (see ./lua/vscode/colors.lua)
      color_overrides = {
        vscLineNumber = "#FFFFFF",
      },

      -- Override highlight groups (see ./lua/vscode/theme.lua)
      group_overrides = {
        -- this supports the same val table as vim.api.nvim_set_hl
        -- use colors from this colorscheme by requiring vscode.colors!
        -- Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
      },
    },
    config = function(_, opts)
      local vscode = require("vscode")
      vscode.setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- {
  -- 	"christianchiarulli/nvcode-color-schemes.vim",
  -- 	lazy = false, -- make sure we load this during startup if it is your main colorscheme
  -- 	priority = 1000, -- make sure to load this before all the other start plugins
  -- 	config = function()
  -- 		-- load the colorscheme here
  -- 		vim.g.nvcode_termcolors = 256
  -- 		vim.cmd.colorscheme("nvcode")
  -- 		vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
  -- 		vim.api.nvim_set_hl(0, "NonText", { bg = "none", ctermbg = "none", fg = "none", ctermfg = "none" })
  -- 		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none", ctermbg = "none", fg = "none", ctermfg = "none" })
  -- 		vim.api.nvim_set_hl(0, "LineNr", { bg = "none", ctermbg = "none" })
  -- 		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", ctermbg = "none" })
  -- 	end,
  -- },

  -- nvim-notify
  {
    "rcarriga/nvim-notify",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      background_colour = "#000000",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- nvim-origami
  {
    "chrisgrieser/nvim-origami",
    event = { "BufReadPost", "BufNewFile" },
    config = true,
  },

  -- windows.nvim
  {
    "anuvyklack/windows.nvim",
    dependencies = { "anuvyklack/animation.nvim", "anuvyklack/middleclass" },
    config = true,
    keys = {
      { "<C-w>z", "<cmd>WindowsMaximize<CR>", desc = "Max out current window" },
      {
        "<C-w>_",
        "<cmd>WindowsMaximizeVertically<CR>",
        desc = "Max out window height",
      },
      {
        "<C-w>|",
        "<cmd>WindowsMaximizeHorizontally<CR>",
        desc = "Max out window width",
      },
      { "<C-w>=", "<cmd>WindowsEqualize<CR>", desc = "Equalize windows" },
      { "<C-w>v" },
      { "<C-w>s" },
    },
  },

  -- lualine.nvim
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      options = {
        theme = "vscode",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "dashboard" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          { "diagnostics", sources = { "nvim_lsp", "nvim_diagnostic" } },
          --[[ {
            function()
              local ok, m = pcall(require, 'better_escape')
              return ok and m.waiting and '✺' or ''
            end,
          }, ]]
        },
        lualine_c = {
          "filename",
          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"]
                and require("nvim-navic").is_available()
            end,
            color_correction = "static",
          },
        },
        lualine_x = {
          "fileformat",
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1 },
          },
          {
            function()
              return require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
          },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = {
        "man",
        "quickfix",
        "mason",
        "toggleterm",
        "neo-tree",
        "trouble",
        "lazy",
        "nvim-dap-ui",
      },
    },
  },

  -- which-key.nvim
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { rules = false },
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>q", group = "quit/session" },
          { "<leader>f", group = "find" },
          { "<leader>b", group = "buffers" },
          { "<leader>g", group = "git" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "<leader>d", group = "debugger" },
          { "<leader>t", group = "terminal" },
          { "<leader>p", group = "precognition" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gz", group = "surround" },
          { "z", group = "fold" },
        },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add(opts.spec)
    end,
  },

  -- tabby.nvim
  {
    "nanozuki/tabby.nvim",
    config = function()
      local status_ok, tabby = pcall(require, "tabby")
      if not status_ok then
        return
      end

      local filename = require("tabby.filename")
      local util = require("tabby.util")

      local hl_tabline = util.extract_nvim_hl("TabLine")
      local hl_normal = util.extract_nvim_hl("Normal")
      local hl_tabline_sel = util.extract_nvim_hl("TabLineSel")
      local hl_tabline_fill = util.extract_nvim_hl("TabLineFill")
      local hl_menu = util.extract_nvim_hl("PmenuSel")

      local function tab_label(tabid, active)
        local icon = active and "" or ""
        local number = vim.api.nvim_tabpage_get_number(tabid)
        local name = util.get_tab_name(tabid)
        return string.format(" %s %d: %s ", icon, number, name)
      end

      local function tab_label_no_fallback(tabid, active)
        local icon = active and "" or ""
        local fallback = function()
          return ""
        end
        local number = vim.api.nvim_tabpage_get_number(tabid)
        local name = util.get_tab_name(tabid, fallback)
        if name == "" then
          return string.format(" %s %d ", icon, number)
        end
        return string.format(" %s %d: %s ", icon, number, name)
      end

      local function win_label(winid, top)
        local icon = top and "" or ""
        local fname = require("tabby.filename").tail(winid)
        local extension = vim.fn.fnamemodify(fname, ":e")
        local fileIcon = require("nvim-web-devicons").get_icon(fname, extension)
        local buid = vim.api.nvim_win_get_buf(winid)
        local is_modified = vim.api.nvim_buf_get_option(buid, "modified")
        local modifiedIcon = is_modified and "" or ""
        return string.format(
          " %s  %s %s %s",
          icon,
          fileIcon,
          filename.unique(winid),
          modifiedIcon
        )
      end

      ---@type table<TabbyTablineLayout, TabbyTablineOpt>
      local tabline = {
        active_wins_at_tail = {
          hl = "TabLineFill",
          layout = "active_wins_at_tail",
          head = {
            { "  ", hl = { fg = hl_menu.fg, bg = hl_menu.bg } },
          },
          active_tab = {
            label = function(tabid)
              return {
                tab_label_no_fallback(tabid, true),
                hl = { fg = hl_menu.fg, bg = hl_menu.bg, style = "bold" },
              }
            end,
            left_sep = {
              " ",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              " ",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                tab_label_no_fallback(tabid),
                hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = "bold" },
              }
            end,
            left_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
          top_win = {
            label = function(winid)
              return {
                win_label(winid, true),
                hl = "TabLineFill",
              }
            end,
            left_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
          win = {
            label = function(winid)
              return {
                win_label(winid),
                hl = "TabLine",
              }
            end,
            left_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              " ",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
        },
        active_wins_at_end = {
          hl = "TabLineFill",
          layout = "active_wins_at_end",
          head = {
            { "  ", hl = { fg = hl_tabline.fg, bg = hl_tabline.bg } },
            { "", hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
          },
          active_tab = {
            label = function(tabid)
              return {
                tab_label(tabid, true),
                hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = "bold" },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                tab_label(tabid),
                hl = {
                  fg = hl_tabline_sel.fg,
                  bg = hl_tabline_sel.bg,
                  style = "bold",
                },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
          },
          top_win = {
            label = function(winid)
              return {
                win_label(winid, true),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
          win = {
            label = function(winid)
              return {
                win_label(winid),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
        },
        active_tab_with_wins = {
          hl = "TabLineFill",
          layout = "active_tab_with_wins",
          head = {
            {
              "  ",
              hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = "italic" },
            },
            { "", hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
          },
          active_tab = {
            label = function(tabid)
              return {
                tab_label(tabid, true),
                hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = "bold" },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                tab_label(tabid),
                hl = {
                  fg = hl_tabline_sel.fg,
                  bg = hl_tabline_sel.bg,
                  style = "bold",
                },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
          },
          top_win = {
            label = function(winid)
              return {
                win_label(winid, true),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
          win = {
            label = function(winid)
              return {
                win_label(winid),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
        },
        tab_with_top_win = {
          hl = "TabLineFill",
          layout = "tab_with_top_win",
          head = {
            {
              "  ",
              hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = "italic" },
            },
            { "", hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
          },
          active_tab = {
            label = function(tabid)
              return {
                tab_label_no_fallback(tabid, true),
                hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = "bold" },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg },
            },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                tab_label_no_fallback(tabid),
                hl = {
                  fg = hl_tabline_sel.fg,
                  bg = hl_tabline_sel.bg,
                  style = "bold",
                },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
          },
          active_win = {
            label = function(winid)
              return {
                win_label(winid, true),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
          win = {
            label = function(winid)
              return {
                win_label(winid),
                hl = "TabLine",
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
        },
        tab_only = {
          hl = "TabLineFill",
          layout = "tab_only",
          head = {
            { "  ", hl = { fg = hl_tabline.fg, bg = hl_tabline.bg } },
            { "", hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
          },
          active_tab = {
            label = function(tabid)
              return {
                tab_label(tabid, true),
                hl = {
                  fg = hl_tabline_sel.fg,
                  bg = hl_tabline_sel.bg,
                  style = "bold",
                },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg },
            },
          },
          inactive_tab = {
            label = function(tabid)
              return {
                tab_label(tabid, false),
                hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = "bold" },
              }
            end,
            left_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
            right_sep = {
              "",
              hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg },
            },
          },
        },
      }

      tabby.setup({
        tabline = tabline.active_wins_at_tail,
      })
    end,
  },
}
