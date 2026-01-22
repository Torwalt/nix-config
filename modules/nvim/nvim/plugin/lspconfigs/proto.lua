vim.lsp.config("buf_ls", {
    cmd = { "buf", "lsp", "serve", "--timeout", "0" },
    filetypes = { "proto" },
    root_markers = { "buf.yaml" },

})

vim.lsp.enable("buf_ls")
