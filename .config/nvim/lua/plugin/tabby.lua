local status_ok, tabby = pcall(require, "tabby")
if not status_ok then
  return
end

local filename = require('tabby.filename')
local util = require('tabby.util')

local hl_tabline = util.extract_nvim_hl('TabLine')
local hl_normal = util.extract_nvim_hl('Normal')
local hl_tabline_sel = util.extract_nvim_hl('TabLineSel')
local hl_tabline_fill = util.extract_nvim_hl('TabLineFill')
local hl_menu = util.extract_nvim_hl('PmenuSel')

local function tab_label(tabid, active)
  local icon = active and '' or ''
  local number = vim.api.nvim_tabpage_get_number(tabid)
  local name = util.get_tab_name(tabid)
  return string.format(' %s %d: %s ', icon, number, name)
end

local function tab_label_no_fallback(tabid, active)
  local icon = active and '' or ''
  local fallback = function()
    return ''
  end
  local number = vim.api.nvim_tabpage_get_number(tabid)
  local name = util.get_tab_name(tabid, fallback)
  if name == '' then
    return string.format(' %s %d ', icon, number)
  end
  return string.format(' %s %d: %s ', icon, number, name)
end

local function win_label(winid, top)
  local icon = top and '' or ''
  local fname = require("tabby.filename").tail(winid)
  local extension = vim.fn.fnamemodify(fname, ':e')
  local fileIcon = require 'nvim-web-devicons'.get_icon(fname, extension)
  local buid = vim.api.nvim_win_get_buf(winid)
  local is_modified = vim.api.nvim_buf_get_option(buid, 'modified')
  local modifiedIcon = is_modified and '' or ''
  return string.format(' %s  %s %s %s', icon, fileIcon, filename.unique(winid), modifiedIcon)
end

---@type table<TabbyTablineLayout, TabbyTablineOpt>
local tabline = {
  active_wins_at_tail = {
    hl = 'TabLineFill',
    layout = 'active_wins_at_tail',
    head = {
      { '  ', hl = { fg = hl_menu.fg, bg = hl_menu.bg } },
    },
    active_tab = {
      label = function(tabid)
        return {
          tab_label_no_fallback(tabid, true),
          hl = { fg = hl_menu.fg, bg = hl_menu.bg, style = 'bold' },
        }
      end,
      left_sep = { ' ', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
      right_sep = { ' ', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
    },
    inactive_tab = {
      label = function(tabid)
        return {
          tab_label_no_fallback(tabid),
          hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = 'bold' },
        }
      end,
      left_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    top_win = {
      label = function(winid)
        return {
          win_label(winid, true),
          hl = 'TabLineFill',
        }
      end,
      left_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    win = {
      label = function(winid)
        return {
          win_label(winid),
          hl = 'TabLine',
        }
      end,
      left_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { ' ', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
  },
  active_wins_at_end = {
    hl = 'TabLineFill',
    layout = 'active_wins_at_end',
    head = {
      { '  ', hl = { fg = hl_tabline.fg, bg = hl_tabline.bg } },
      { '',   hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    active_tab = {
      label = function(tabid)
        return {
          tab_label(tabid, true),
          hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
    },
    inactive_tab = {
      label = function(tabid)
        return {
          tab_label(tabid),
          hl = { fg = hl_tabline_sel.fg, bg = hl_tabline_sel.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
    },
    top_win = {
      label = function(winid)
        return {
          win_label(winid, true),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    win = {
      label = function(winid)
        return {
          win_label(winid),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
  },
  active_tab_with_wins = {
    hl = 'TabLineFill',
    layout = 'active_tab_with_wins',
    head = {
      { '  ', hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = 'italic' } },
      { '',   hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    active_tab = {
      label = function(tabid)
        return {
          tab_label(tabid, true),
          hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
    },
    inactive_tab = {
      label = function(tabid)
        return {
          tab_label(tabid),
          hl = { fg = hl_tabline_sel.fg, bg = hl_tabline_sel.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
    },
    top_win = {
      label = function(winid)
        return {
          win_label(winid, true),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    win = {
      label = function(winid)
        return {
          win_label(winid),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
  },
  tab_with_top_win = {
    hl = 'TabLineFill',
    layout = 'tab_with_top_win',
    head = {
      { '  ', hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = 'italic' } },
      { '',   hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    active_tab = {
      label = function(tabid)
        return {
          tab_label_no_fallback(tabid, true),
          hl = { fg = hl_normal.fg, bg = hl_normal.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_normal.bg, bg = hl_tabline_fill.bg } },
    },
    inactive_tab = {
      label = function(tabid)
        return {
          tab_label_no_fallback(tabid),
          hl = { fg = hl_tabline_sel.fg, bg = hl_tabline_sel.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
    },
    active_win = {
      label = function(winid)
        return {
          win_label(winid, true),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    win = {
      label = function(winid)
        return {
          win_label(winid),
          hl = 'TabLine',
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
  },
  tab_only = {
    hl = 'TabLineFill',
    layout = 'tab_only',
    head = {
      { '  ', hl = { fg = hl_tabline.fg, bg = hl_tabline.bg } },
      { '',   hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
    active_tab = {
      label = function(tabid)
        return {
          tab_label(tabid, true),
          hl = { fg = hl_tabline_sel.fg, bg = hl_tabline_sel.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline_sel.bg, bg = hl_tabline_fill.bg } },
    },
    inactive_tab = {
      label = function(tabid)
        return {
          tab_label(tabid, false),
          hl = { fg = hl_tabline.fg, bg = hl_tabline.bg, style = 'bold' },
        }
      end,
      left_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
      right_sep = { '', hl = { fg = hl_tabline.bg, bg = hl_tabline_fill.bg } },
    },
  },
}

tabby.setup {
  tabline = tabline.active_wins_at_tail,
}
