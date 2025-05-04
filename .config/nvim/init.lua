-- Enable experimental loader
vim.loader.enable()

-- Use pcall to load the modules
---@param module string
local function safe_require(module)
  ---@type boolean, any
  local success, err_msg = pcall(require, module)
  if not success then
    local msg = ("Error loading %s\n%s"):format(module, err_msg)
    vim.defer_fn(function()
      vim.notify(msg, vim.log.levels.ERROR)
    end, 1000)
  end
end

-- Load the files
safe_require("core.options")
safe_require("core.keymaps")
safe_require("core.autocommands")
safe_require("core.bootstrap")
