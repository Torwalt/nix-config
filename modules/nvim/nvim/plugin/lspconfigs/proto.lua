vim.lsp.config("buf_ls", {
    cmd = { "buf", "lsp", "serve" },
    filetypes = { "proto" },
    root_markers = { "buf.yaml" },

    handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
    },
})

vim.lsp.enable("buf_ls")
