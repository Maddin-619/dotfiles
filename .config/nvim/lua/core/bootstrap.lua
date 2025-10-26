-- Install lazy.nvim automatically
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load the plugins and options
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  rocks = { enabled = false },
  git = { log = { "--since=3 days ago" }, timeout = 60 },
  ui = { custom_keys = { false }, backdrop = 100 },
  install = { colorscheme = { "vscode" } },
  checker = { enabled = true },
  diff = {
    cmd = "terminal_git",
    -- cmd = 'git',
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "rplugin",
        "matchparen",
        "matchit",
      },
    },
  },
})
