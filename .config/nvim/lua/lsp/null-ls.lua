local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

local command_ext = ""
if vim.loop.os_uname().sysname == "Windows_NT" then
  command_ext = ".cmd"
end

null_ls.setup({
  debug = false,
  sources = {
    formatting.prettier.with({
      filetypes = { "html", "json", "yaml", "markdown" },
      command = "prettier" .. command_ext,
    }),
    formatting.eslint_d.with({ command = "eslint_d" .. command_ext }),
    formatting.black.with({ extra_args = { "--fast" } }),
    diagnostics.eslint_d,
    diagnostics.eslint_d.with({ command = "eslint_d" .. command_ext }),
    -- diagnostics.flake8
  },
  on_attach = function(client)
    if client.resolved_capabilities.document_formatting then
      vim.cmd([[
          augroup LspFormatting
              autocmd! * <buffer>
              autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
          augroup END
          ]])
    end
  end,
})
