local autocmd = vim.api.nvim_create_autocmd
---@param name string
---@return integer
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight text on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = "500" })
  end,
})

-- Automatically rebalance windows on vim resize
autocmd(
  "VimResized",
  { group = augroup("resize_splits"), command = "tabdo wincmd =" }
)

-- Never insert line as a comment when using 'o' to enter insert mode
autocmd(
  "BufWinEnter",
  { group = augroup("no_comment_on_o"), command = "setlocal formatoptions-=o" }
)

-- Close various file types with just <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "checkhealth", "qf", "query", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set(
      "n",
      "q",
      vim.cmd.close,
      { buffer = event.buf, silent = true }
    )
  end,
})

-- Fix manpage bugs
autocmd("FileType", {
  group = augroup("man_bugfixes"),
  pattern = { "man" },
  callback = function(event)
    vim.opt_local.signcolumn = "no"
    vim.bo[event.buf].buflisted = false
  end,
})

-- Auto create dir when saving a file where some intermediate directory does not exist
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Check for spelling in text filetypes and enable wrapping
autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "text", "NeogitCommitMessage" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

-- Check if the file needs to be reloaded when it's changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

-- Toggle relative numbers based on certain events
autocmd({ "BufEnter", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
  group = augroup("auto_relative_numbers_on"),
  callback = function()
    if vim.o.number and vim.api.nvim_get_mode() ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})

autocmd({ "BufLeave", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
  group = augroup("auto_relative_numbers_off"),
  callback = function()
    if vim.o.number then
      vim.opt.relativenumber = false
      vim.cmd.redraw()
    end
  end,
})

-- Disable conceallevel for json filetypes
autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Kill prettierd after leaving neovim
-- HACK: If there are other instances of neovim open with prettierd active,
-- it will also kill those instances as well
-- Borrowed from: https://github.com/fsouza/prettierd/issues/645#issuecomment-2143341193
autocmd("VimLeavePre", {
  group = augroup("kill_neovim_daemons"),
  callback = function()
    vim.fn.jobstart("killall prettierd", { detach = true })
  end,
})

-- Turn off line numbers etc
autocmd("FileType", {
  pattern = "ErgoTerm",
  callback = function()
    vim.opt_local.list = false
    vim.opt_local.listchars = ""
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Make sure that enter is never overridden in the quickfix window
autocmd("BufReadPost", {
  pattern = "quickfix",
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<CR>",
      "<CR>",
      { noremap = true, silent = true }
    )
  end,
})

-- Custom mapping for the quickfix window
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader><Enter>",
      "<C-w><Enter><C-w>L",
      { noremap = true, silent = true }
    )
  end,
})
