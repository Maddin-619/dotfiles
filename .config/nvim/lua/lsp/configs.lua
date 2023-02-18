local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
  return
end

local lspconfig = require("lspconfig")
--[[ local coq = require("coq") ]]
local servers = { "jsonls", "lua_ls" }

local function setup(server_name)
  local opts = {
    on_attach = require("lsp.handlers").on_attach,
    capabilities = require("lsp.handlers").capabilities,
  }
  local has_custom_opts, server_custom_opts = pcall(require, "lsp.settings." .. server_name)
  if has_custom_opts then
    opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
  end
  --[[ lspconfig[server_name].setup(coq.lsp_ensure_capabilities(opts)) ]]
  lspconfig[server_name].setup(opts)
end

mason_lspconfig.setup({
  ensure_installed = servers,
})

-- Manually setup ccls because it is not managed by mason
setup("ccls")

mason_lspconfig.setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  setup,
})
