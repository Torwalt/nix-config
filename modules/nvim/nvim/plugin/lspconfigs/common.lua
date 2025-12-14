require("lsp-format").setup {}

vim.lsp.config('*', {
  on_attach = on_attach,
})

vim.lsp.set_log_level("warn")

