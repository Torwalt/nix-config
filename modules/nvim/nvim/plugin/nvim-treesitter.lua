local api = vim.api

local function ts_disable(lang, bufnr)
    local disabled_langs = {"yaml", "json"}
    local line_count_exceeds = api.nvim_buf_line_count(bufnr) > 5000

    for _, l in ipairs(disabled_langs) do
        if l == lang then return line_count_exceeds end
    end

    return false
end

require('nvim-treesitter.configs').setup {
    ensure_installed = {},
    auto_install = false,
    highlight = {
        enable = true,
        disable = ts_disable,
        additional_vim_regex_highlighting = false
    },
    indent = {
        enable = true,
        disable = ts_disable
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@function.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@function.outer",
            },
        },
    },
}

nmap("[[", function()
    require('nvim-treesitter.textobjects.move').goto_previous_start('@function.outer')
end)

nmap("]]", function()
    require('nvim-treesitter.textobjects.move').goto_next_start('@function.outer')
end)

