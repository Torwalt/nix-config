-- special snowflake treatment: vim.g.rustaceanvim must appear before any require(rustaceanvim).

local rust_on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    nbufmap("<leader>cc", function() vim.cmd.RustLsp("codeAction") end, bufnr)
    nbufmap("<leader>rr", function() vim.cmd.RustLsp({ "flyCheck", "run" }) end,
        bufnr)
    nbufmap("<leader>rh", function() vim.cmd.RustLsp({ "view", "hir" }) end, bufnr)
    nbufmap("<leader>rm", function() vim.cmd.RustLsp({ "view", "mir" }) end, bufnr)
    nbufmap("<leader>rt", function() vim.cmd.RustLsp({ "testables" }) end, bufnr)
    nbufmap("<leader>rT",
        function() vim.cmd.RustLsp({ "testables", bang = true }) end, bufnr)
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
            code_actions = { ui_select_fallback = true }
        },
        server = {
            cmd = { "rust-analyzer" },

            on_attach = rust_on_attach,

            default_settings = {
                ["rust-analyzer"] = {
                    cargo = { buildScripts = { enable = true }, allTargets = true, allFeatures = true },
                    hover = {
                        actions = {
                            implementations = true,
                            references = true,
                            run = true
                        }
                    },
                    imports = {
                        granularity = { group = "module" },
                        prefix = "self"
                    },
                    inlayHints = {
                        bindingModeHints = { enable = true },
                        closureCaptureHints = { enable = true },
                        closureReturnTypeHints = { enable = "always" },
                        genericParameterHints = {
                            lifetime = { enable = true },
                            type = { enable = true }
                        },
                        lifetimeElisionHints = {
                            enable = "skip_trivial",
                            useParameterNames = true
                        },
                        maxLength = nil
                    },
                    procMacro = { enable = true },
                    rust = { analyzerTargetDir = true }
                }
            }
        }
    }
end
