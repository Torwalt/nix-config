vim.lsp.config('lua_ls', {
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                -- Recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                }
            }
        }
    }
})

vim.lsp.enable('lua_ls', true)

