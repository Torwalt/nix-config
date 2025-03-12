local util = require "lspconfig/util"

local on_attach = function(_, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
                   opts)
    buf_set_keymap('n', '<leader>wa',
                   '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr',
                   '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl',
                   '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                   opts)
    buf_set_keymap('n', '<leader>D',
                   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                   opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>',
                   opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>',
                   opts)
    buf_set_keymap('n', '<leader>F',
                   '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
end

local lspconfig = require("lspconfig")

vim.lsp.set_log_level("debug")

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    cmd = {"lua-lsp"},
    settings = {
        Lua = {
            workspace = {checkThirdParty = false},
            telemetry = {enable = false},
            format = {
                enable = true,
                defaultConfig = {
                indent_style = "space",
                    indent_size = "4",
                }
            }
        }
    }
}

require("lsp-format").setup {}

local go_on_attach = function(client, bufnr)
    require"lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

lspconfig.gopls.setup {
    on_attach = go_on_attach,
    init_options = {buildFlags = {"-tags=clickhouse,integration"}}
}

lspconfig.solargraph.setup {
    on_attach = on_attach,
    settings = {
        solargraph = {
            autoformat = false,
            formatting = false,
            completion = true,
            diagnostic = true,
            folding = true,
            references = true,
            rename = true,
            symbols = true
        }
    }
}

lspconfig.intelephense.setup {on_attach = on_attach}

lspconfig.jdtls.setup {on_attach = on_attach}

lspconfig.terraformls.setup {on_attach = on_attach}
lspconfig.yamlls.setup {on_attach = on_attach, autostart = false}
lspconfig.jsonls.setup {on_attach = on_attach}
-- lspconfig.eslint.setup {on_attach = on_attach}
lspconfig.pyright.setup {on_attach = on_attach}

lspconfig.nil_ls.setup {
    on_attach = on_attach,
    settings = {
        ['nil'] = {
          testSetting = 42,
          formatting = {
            command = { "nixfmt" },
          },
        },
      }
}

lspconfig.wgsl_analyzer.setup({})

local sqls_on_attach = function(client, bufnr)
    require"lsp-format".on_attach(client)
    on_attach(client, bufnr)
    require('sqls').on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

local rust_on_attach = function(_, bufnr)
    on_attach(nil, bufnr)

    nbufmap("<leader>cc", function() vim.cmd.RustLsp("codeAction") end, bufnr)
    nbufmap("<leader>rr", function() vim.cmd.RustLsp({"flyCheck", "run"}) end,
            bufnr)
    nbufmap("<leader>rh", function() vim.cmd.RustLsp({"view", "hir"}) end, bufnr)
    nbufmap("<leader>rm", function() vim.cmd.RustLsp({"view", "mir"}) end, bufnr)
    nbufmap("<leader>rt", function() vim.cmd.RustLsp({"testables"}) end, bufnr)
    nbufmap("<leader>rT",
            function() vim.cmd.RustLsp({"testables", bang = true}) end, bufnr)
    nbufmap("<leader>F", ":RustFmt<cr>", bufnr)
end

local executors = require("rustaceanvim.executors")
vim.g.rustaceanvim = function()
    return {
        tools = {
            executor = executors.toggleterm,
            test_executor = "neotest",
            crate_test_executor = "neotest",
            enable_clippy = true,
            enable_nextest = true,
            code_actions = {ui_select_fallback = true}
        },
        server = {
            cmd = {"rust-analyzer"},

            on_attach = rust_on_attach,

            settings = {
                ["rust-analyzer"] = {
                    cargo = {buildScripts = {enable = true}, allTargets = true},
                    hover = {
                        actions = {
                            implementations = true,
                            references = true,
                            run = true
                        }
                    },
                    imports = {
                        granularity = {group = "module"},
                        prefix = "self"
                    },
                    inlayHints = {
                        bindingModeHints = {enable = true},
                        closureCaptureHints = {enable = true},
                        closureReturnTypeHints = {enable = "always"},
                        genericParameterHints = {
                            lifetime = {enable = true},
                            type = {enable = true}
                        },
                        lifetimeElisionHints = {
                            enable = "skip_trivial",
                            useParameterNames = true
                        },
                        maxLength = nil
                    },
                    procMacro = {enable = true},
                    rust = {analyzerTargetDir = true}
                }
            }
        }
    }
end


lspconfig.ts_ls.setup {
    -- Command to start the language server
    cmd = { "typescript-language-server", "--stdio" },
    
    -- Performance optimizations
    flags = {
      debounce_text_changes = 150,      -- Debounce time in ms
      allow_incremental_sync = true,    -- Enable incremental document sync
    },
    
    -- Customize capabilities
    capabilities = (function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      
      -- Limit some features that might be causing performance issues
      capabilities.textDocument.codeAction = {
        dynamicRegistration = false,
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = {
              "quickfix",
              "refactor",
              "refactor.extract",
              "refactor.inline",
              "refactor.rewrite",
              "source",
              "source.organizeImports",
            }
          }
        }
      }
      
      return capabilities
    end)(),
    
    settings = {
      typescript = {
        inlayHints = {
          -- Disable inlay hints which can cause performance issues
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        suggest = {
          completeFunctionCalls = false, -- Can be expensive
        },
        implementationsCodeLens = false,  -- Disable code lens which can be expensive
        referencesCodeLens = false,       -- Disable code lens which can be expensive
        tsserver = {
          maxTsServerMemory = 4096,      -- Limit memory usage to prevent bloat
          useSyntaxServer = "auto",      -- Use syntax server for lighter operations
          watchOptions = {
            watchFile = "useFsEvents",   -- More efficient file watching
            watchDirectory = "useFsEvents",
            fallbackPolling = "dynamicPriority",
          }
        }
      },
      javascript = {
        inlayHints = {
          -- Same hint disables for JavaScript
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        -- Same settings as TypeScript
        suggest = {
          completeFunctionCalls = false,
        },
        implementationsCodeLens = false,
        referencesCodeLens = false,
      }
    },
    
    -- Initialize options
    init_options = {
      hostInfo = "neovim",
      disableAutomaticTypingAcquisition = true, -- Prevent automatic downloading of type definitions
      maxTsServerMemory = 4096,
      tsserver = {
        logVerbosity = "off", -- Reduce verbose logging
      }
    },

    on_attach = on_attach
}
