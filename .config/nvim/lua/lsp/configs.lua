local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
  return
end

local lspconfig = require("lspconfig")

local servers = { "jsonls", "sumneko_lua" }

mason_lspconfig.setup({
  ensure_installed = servers,
})

lspconfig.ccls.setup {}

mason_lspconfig.setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    local opts = {
      on_attach = require("lsp.handlers").on_attach,
      capabilities = require("lsp.handlers").capabilities,
    }
    local has_custom_opts, server_custom_opts = pcall(require, "lsp.settings." .. server_name)
    if has_custom_opts then
      opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
    end
    lspconfig[server_name].setup(opts)
  end,
})