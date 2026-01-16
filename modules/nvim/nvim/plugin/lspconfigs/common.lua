require("lsp-format").setup {}

cmp_caps = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config('*', {
    on_attach = on_attach,
    capabilities = cmp_caps,
})

vim.lsp.set_log_level("warn")
