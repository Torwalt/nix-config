require("lsp-format").setup {}

cmp_caps = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config('*', {
    on_attach = on_attach,
    capabilities = cmp_caps,
})

vim.lsp.set_log_level("warn")

-- Closes buffers whose file is gone, unsaved changes included; the current window falls back to netrw at the cwd.
-- Re-reads buffers changed on disk, then restarts the LSP so files that are not open are re-read too.
-- Plain :checktime skips buffers without a window.
nmap("<leader>R", function()
    local client_names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client_names[client.name] = true
    end

    local file_bufs = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
    end, vim.api.nvim_list_bufs())
    for _, buf in ipairs(file_bufs) do
        if vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf)) == nil then
            if buf == vim.api.nvim_get_current_buf() then
                vim.cmd("Explore " .. vim.fn.fnameescape(vim.fn.getcwd()))
            end
            vim.api.nvim_buf_delete(buf, { force = true })
        else
            vim.cmd("checktime " .. buf)
        end
    end

    if next(client_names) then
        vim.cmd("lsp restart " .. table.concat(vim.tbl_keys(client_names), " "))
    end
end)
