vim.lsp.config('nil_ls', {
    on_attach = on_attach,
    settings = {
        ['nil'] = {
            testSetting = 42,
            formatting = {
                command = { "nixfmt" },
            },
        },
    }
})

vim.lsp.enable('nil_ls', true)
