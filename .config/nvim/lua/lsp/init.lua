local lsp_status = require("lsp-status")
local status = require("lsp_status")
local lspconfig = require 'lspconfig'
local util = require 'lspconfig/util'

function DoFormat()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    print(string.format("Formatting for attached client: %s", client.name))
  end

  vim.lsp.buf.formatting_sync(nil, 1000)
end

local attach_formatting = function(client)
  -- Skip tsserver for now so we dont format things twice
  if client.name == "tsserver" then return end
  if client.name == "cssls" then return end

  print(string.format("attaching format to %s", client.name))

  vim.api.nvim_command [[augroup LSPFormat]]
  vim.api.nvim_command [[autocmd! * <buffer>]]
  vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)]]
  vim.api.nvim_command [[augroup END]]
end

local setup = function()
  status.activate()

  --- Language servers
  local on_attach_vim = function(client)

    lsp_status.register_client(client.name)

    print("'" .. client.name .. "' language server attached")

    lsp_status.on_attach(client)

    if client.resolved_capabilities.document_formatting then
      print(string.format("Formatting supported %s", client.name))

      attach_formatting(client)
    end

  end
  -- enable lsp capabilities
  local capabilities = lsp_status.capabilities
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  }
  local default_lsp_config = {on_attach = on_attach_vim, capabilities = capabilities}

  local servers = {"bashls", "dockerls", "gopls", "graphql", "pyright", "vimls", "yamlls", "rust_analyzer", "html", "cssls"}

  for _, server in ipairs(servers) do lspconfig[server].setup(default_lsp_config) end

  lspconfig.ccls.setup {
    init_options = {
      compilationDatabaseDirectory = "build";
      index = {
        threads = 0;
      };
      clang = {
        excludeArgs = { "-frounding-math"} ;
      };
    },
    capabilities = capabilities
  }

  lspconfig.groovyls.setup{
      -- Unix
      cmd = { "java", "-jar", "~/.config/nvim/lua/lsp/groovy-language-server-all.jar" },
  }

  local eslint = {
    lintCommand = "eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {
      "%f(%l,%c): %tarning %m",
      "%f(%l,%c): %rror %m"
    },
    lintIgnoreExitCode = true,
    formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
  }

  local function eslint_config_exists()
    local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

    if not vim.tbl_isempty(eslintrc) then
      return true
    end

    if vim.fn.filereadable("package.json") then
      if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
        return true
      end
    end

    return false
  end

  lspconfig.tsserver.setup {
    on_attach = function(client)
      if client.config.flags then
        client.config.flags.allow_incremental_sync = true
      end
      client.resolved_capabilities.document_formatting = false
      on_attach_vim(client)
    end,
    capabilities = capabilities
  }

  lspconfig.efm.setup {
    init_options = {document_formatting = true},
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = true
      client.resolved_capabilities.goto_definition = false
      on_attach_vim(client)
    end,
    root_dir = function(fname)
      return util.root_pattern(".git")(fname) or util.path.dirname(fname)
    end,
    settings = {
      languages = {
        javascript = {eslint},
        javascriptreact = {eslint},
        ["javascript.jsx"] = {eslint},
        typescript = {eslint},
        ["typescript.tsx"] = {eslint},
        typescriptreact = {eslint}
      }
    },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescript.tsx",
      "typescriptreact"
    },
    capabilities = capabilities
  }

  -- JSON
  lspconfig.jsonls.setup {
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
        end
      }
    },
    capabilities = capabilities,
    on_attach = on_attach_vim,
  }

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  lspconfig.sumneko_lua.setup {
    cmd = {'/usr/bin/lua-language-server'};
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
    capabilities = capabilities,
    on_attach = on_attach_vim,
  }
end

return {setup = setup}
