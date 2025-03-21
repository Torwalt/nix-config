local api = vim.api

local function gitblame_disable()
    local bufnr = api.nvim_get_current_buf()
    local line_count_exceeds = api.nvim_buf_line_count(bufnr) > 5000
    return line_count_exceeds
end

require('gitblame').setup {
    enabled = true
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
    callback = function()
        local should_disable = gitblame_disable()
        vim.g.gitblame_enabled = should_disable and 0 or 1
    end
})
