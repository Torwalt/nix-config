local go_on_attach = function(client, bufnr)
    require "lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

vim.lsp.config('gopls', {
    on_attach = go_on_attach,
    init_options = { buildFlags = { "-tags=clickhouse,integration" } }
})

vim.lsp.enable('gopls', true)
