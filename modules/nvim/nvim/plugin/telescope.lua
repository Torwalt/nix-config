local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local t_actions = require('telescope.actions')
local t_action_state = require('telescope.actions.state')
local t_pickers = require('telescope.pickers')
local t_finders = require('telescope.finders')
local t_conf_vals = require('telescope.config').values

telescope.setup {
    defaults = {
        vimgrep_arguments = {
            'rg', '--with-filename', '--line-number', '--column',
            '--smart-case', '-uu'
        },
        mappings = {
            n = { ['<c-d>'] = require('telescope.actions').delete_buffer },
            i = {
                ["<C-j>"] = t_actions.cycle_history_next,
                ["<C-k>"] = t_actions.cycle_history_prev,
            },
        },
        history = {
            path = vim.fn.stdpath('data') .. '/telescope_history',
            limit = 100,
        },
    },
    extensions = {
        live_grep_args = {
            auto_quoting = true,
            mappings = {
                i = {
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                }
            }
        }
    },
    pickers = {
        current_buffer_fuzzy_find = {
            sorter = t_conf_vals.generic_sorter({}),
            previewer = false
        }
    }
}

telescope.load_extension("emoji")
nmap("<leader>fe", function() telescope.extensions.emoji.emoji() end)

telescope.load_extension('luasnip')
nmap("<leader>fs", function() telescope.extensions.luasnip.luasnip() end)

local tele_builtin = require('telescope.builtin')
nmap("<leader>ff", function() tele_builtin.find_files({ hidden = true }) end)
nmap("<leader>fb", function() tele_builtin.buffers({ sort_mru = true }) end)
nmap("/", function() tele_builtin.current_buffer_fuzzy_find({ sort_mru = true }) end)

telescope.load_extension("live_grep_args")
nmap("<leader>fw",
    function() telescope.extensions.live_grep_args.live_grep_args() end)

local t_commands = {
    {
        desc = "Convert to camel case",
        command = "lua require('textcase').current_word('to_camel_case')"
    }, {
    desc = "Convert to constant case",
    command = "lua require('textcase').current_word('to_constant_case')"
}, {
    desc = "Convert to upper case",
    command = "lua require('textcase').current_word('to_upper_case')"
}, {
    desc = "Convert to snake case",
    command = "lua require('textcase').current_word('to_snake_case')"
}
}

-- Allows search, selection and execution of commands defined in t_commands.
local function t_command_picker()
    t_pickers.new({}, {
        prompt_title = "Custom Commands",
        finder = t_finders.new_table({
            results = t_commands,
            entry_maker = function(item)
                return { value = item, display = item.desc, ordinal = item.desc }
            end
        }),
        sorter = t_conf_vals.generic_sorter({}),
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local selection = t_action_state.get_selected_entry()
                t_actions.close(prompt_bufnr)
                vim.cmd(selection.value.command)
            end)
            map('n', '<CR>', function(prompt_bufnr)
                local selection = t_action_state.get_selected_entry()
                t_actions.close(prompt_bufnr)
                vim.cmd(selection.value.command)
            end)
            return true
        end
    }):find()
end

nmap('<leader>fc', t_command_picker)
