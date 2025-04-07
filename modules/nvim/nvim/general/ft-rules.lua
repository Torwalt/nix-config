vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", ".md", "telekasten" },
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
