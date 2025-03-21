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
