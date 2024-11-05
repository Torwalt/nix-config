local api = vim.api

local function ts_disable(lang, bufnr)
    local disabled_langs = { "yaml", "json" }
    local line_count_exceeds = api.nvim_buf_line_count(bufnr) > 5000

    for _, l in ipairs(disabled_langs) do
        if l == lang then
            return line_count_exceeds
        end
    end

    return false
end

require 'nvim-treesitter.configs'.setup {
  ensure_installed = {},
  auto_install = false,
  highlight = {
        enable = true,
        disable = ts_disable
    },
  indent = {
        enable = true,
        disable = ts_disable
    }
}
