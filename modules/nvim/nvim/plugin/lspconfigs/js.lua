lspconfig.astro.setup {
    on_attach = on_attach,
    filetypes = { "astro" },
    root_dir = lspconfig.util.root_pattern("astro.config.mjs", "astro.config.js", "package.json")
}

lspconfig.ts_ls.setup {
    -- Command to start the language server
    cmd = { "typescript-language-server", "--stdio" },

    -- Performance optimizations
    flags = {
        debounce_text_changes = 150,   -- Debounce time in ms
        allow_incremental_sync = true, -- Enable incremental document sync
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
            implementationsCodeLens = false,   -- Disable code lens which can be expensive
            referencesCodeLens = false,        -- Disable code lens which can be expensive
            tsserver = {
                maxTsServerMemory = 8192,      -- Limit memory usage to prevent bloat
                useSyntaxServer = "auto",      -- Use syntax server for lighter operations
                watchOptions = {
                    watchFile = "useFsEvents", -- More efficient file watching
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
        maxTsServerMemory = 8192,
        tsserver = {
            logVerbosity = "off", -- Reduce verbose logging
        },
        preferences = {
            includeCompletionsForModuleExports = false,
        },
    },

    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end
}

local prettier = {
    formatCommand = 'prettierd "${INPUT}"',
    formatStdin = true,
    -- env = {
    --   string.format('PRETTIERD_DEFAULT_CONFIG=%s', vim.fn.expand('~/.config/nvim/utils/linter-config/.prettierrc.json')),
    -- },
}

lspconfig.efm.setup({
    init_options = { documentFormatting = true },
    filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'json' },
    settings = {
        rootMarkers = { ".prettierrc", ".prettierrc.json", ".prettierrc.js", "package.json" },
        languages = {
            typescript = { prettier },
            javascript = { prettier },
            typescriptreact = { prettier },
            javascriptreact = { prettier },
            json = { prettier }
        }
    }
})
