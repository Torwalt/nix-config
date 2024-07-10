function Map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command,
                            {noremap = true, silent = true})
end

function NMap(shortcut, command) Map('n', shortcut, command) end

local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup {
    defaults = {
        vimgrep_arguments = {
            'rg', '--with-filename', '--line-number', '--column',
            '--smart-case', '-uu'
        }
    },
    extensions = {
        live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
                i = {
                    ["<C-k>"] = lga_actions.quote_prompt(),
                    ["<C-i>"] = lga_actions.quote_prompt({postfix = " --iglob "}),
                    -- freeze the current list and start a fuzzy search in the frozen list
                    ["<C-space>"] = lga_actions.to_fuzzy_refine
                }
            }
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
        }
    }
}
--
-- don't forget to load the extension
telescope.load_extension("live_grep_args")

NMap("<leader>ff",
     [[<Cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>]])

NMap("<leader>fw", [[<Cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]])

NMap("<leader>fb",
     [[<Cmd>lua require('telescope.builtin').buffers({ sort_lastused = true })<CR>]])
