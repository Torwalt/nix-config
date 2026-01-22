local go_on_attach = function(client, bufnr)
    require "lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

vim.lsp.config('gopls', {
    on_attach = go_on_attach,
    init_options = { buildFlags = { "-tags=clickhouse,integration" } }
})

vim.lsp.enable('gopls', true)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        -- Otherwise `gqq` (comment linebreaking) will delegate to gofmt which wont linebreak.
        vim.opt_local.formatprg = ""
    end,
})
