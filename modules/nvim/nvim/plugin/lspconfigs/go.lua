local go_on_attach = function(client, bufnr)
    require "lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

lspconfig.gopls.setup {
    on_attach = go_on_attach,
    init_options = { buildFlags = { "-tags=clickhouse,integration" } }
}
