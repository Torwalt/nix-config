vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "md", "telekasten", "hcl" },
    callback = function()
        vim.opt_local.shiftwidth = 2   -- Number of spaces to use for each step of indentation
        vim.opt_local.tabstop = 2      -- Number of spaces a <Tab> counts for
        vim.opt_local.expandtab = true -- Use spaces instead of tabs
    end
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.wgsl",
    callback = function()
        vim.bo.filetype = "wgsl"
    end,
})

vim.filetype.add {
    extension = {
        container = "ini",
        network   = "ini",
        pod       = "ini",
        mount     = "ini",
        service   = "ini",
        pgsql     = "sql",
        envrc     = "bash",
    },
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "/tmp/*",
    callback = function()
        vim.bo.filetype = "markdown"
    end,
})
