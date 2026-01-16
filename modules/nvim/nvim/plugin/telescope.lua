local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local t_actions = require('telescope.actions')
local t_action_state = require('telescope.actions.state')
local t_pickers = require('telescope.pickers')
local t_finders = require('telescope.finders')
local t_conf_vals = require('telescope.config').values
local previewers = require("telescope.previewers")

local function delete_buf(prompt_bufnr)
    -- Get the selected entry
    local selection = require('telescope.actions.state').get_selected_entry()
    local action_state = require('telescope.actions.state')
    local current_picker = action_state.get_current_picker(prompt_bufnr)

    if selection then
        -- Force delete the buffer with !
        vim.cmd('bd! ' .. selection.bufnr)

        -- Remove the entry from the picker
        current_picker:delete_selection(function()
            -- This is the callback that runs after deletion
            current_picker:refresh()
        end)
    end
end


local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}

    vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end

        -- Skip huge files
        if stat.size > 200 * 1024 then
            return
        end

        previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end)
end

telescope.setup {
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--with-filename', '--line-number', '--column',
            '--smart-case',
            '--hidden',
            '--glob', '!.git/*',
            -- optionally: '--no-ignore-vcs'  -- only if you truly need ignored files, but be careful
        },
        file_ignore_patterns = {
            "node_modules/", "dist/", "build/", "target/", "vendor/",
            "%.min%.js", "%.lock",
        },
        mappings = {
            n = {
                ['<c-d>'] = delete_buf
            },
            i = {
                ["<C-j>"] = t_actions.cycle_history_next,
                ["<C-k>"] = t_actions.cycle_history_prev,
            },
        },
        history = {
            path = vim.fn.stdpath('data') .. '/telescope_history',
            limit = 100,
        },
        buffer_previewer_maker = new_maker,
    },
    extensions = {
        live_grep_args = {
            auto_quoting = true,
            mappings = {
                i = {
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                }
            }
        },
        fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    },
    pickers = {
        current_buffer_fuzzy_find = {
            sorter = t_conf_vals.generic_sorter({}),
            previewer = false
        }
    }
}

telescope.load_extension("fzf")

telescope.load_extension("emoji")
nmap("<leader>fe", function() telescope.extensions.emoji.emoji() end)

telescope.load_extension('luasnip')
nmap("<leader>fs", function() telescope.extensions.luasnip.luasnip() end)

local tele_builtin = require('telescope.builtin')

nmap("<leader>ff", function()
    require('telescope.builtin').find_files({
        hidden = true,
        find_command = {
            "fd", "--type", "f",
            "--hidden",
            "--exclude", ".git",
            "--exclude", "node_modules",
            "--exclude", "dist",
            "--exclude", "build",
            "--exclude", "target",
        },
    })
end)

nmap("<leader>fb", function() tele_builtin.buffers({ sort_mru = true }) end)
nmap("/", function() tele_builtin.current_buffer_fuzzy_find({ sort_mru = true }) end)
nmap("<leader>fd", function() tele_builtin.lsp_document_symbols({ sort_mru = true, query = "" }) end)

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
