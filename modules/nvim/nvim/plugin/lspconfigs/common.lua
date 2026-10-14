require("lsp-format").setup {}

cmp_caps = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config('*', {
    on_attach = on_attach,
    capabilities = cmp_caps,
})

vim.lsp.set_log_level("warn")

-- Re-reads buffers changed on disk, then restarts the LSP so files that are not open are re-read too.
-- Plain :checktime skips buffers without a window.
nmap("<leader>R", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
            vim.cmd("checktime " .. buf)
        end
    end
    if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
        vim.cmd("lsp restart")
    end
end)
