local api = vim.api

local function ts_disable(lang, bufnr)
    local disabled_langs = { "yaml", "json" }
    local line_count_exceeds = api.nvim_buf_line_count(bufnr) > 5000

    for _, l in ipairs(disabled_langs) do
        if l == lang then return line_count_exceeds end
    end

    return false
end


require('nvim-treesitter').setup {
    ensure_installed = {},
    auto_install = false,
    indent = {
        enable = true,
        disable = ts_disable
    },
}

api.nvim_create_autocmd("FileType", {
    group = api.nvim_create_augroup("ts-enable", { clear = true }),
    callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        if ts_disable(ft, ev.buf) then
            return
        end

        pcall(vim.treesitter.start, ev.buf, ft)
    end,
})

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
        selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"]  = "V",
            ["@class.outer"]     = "<c-v>",
        },
        include_surrounding_whitespace = true,
    },
    move = {
        set_jumps = true,
    },
})

local sel  = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "x", "o" }, "af", function()
    sel.select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
    sel.select_textobject("@function.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[[", function()
    move.goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
    move.goto_next_start("@function.outer", "textobjects")
end)
