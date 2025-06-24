vim.g.db_ui_auto_execute_table_helpers = 1
vim.g.db_ui_save_location = vim.fn.stdpath("state") .. "/db_ui_history"
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0

vim.keymap.set("n", "<leader>dT", ":DBUIToggle<CR>", { desc = "Toggle DB UI" })

vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("Dadbod", { clear = true }),
    pattern  = "sql",
    callback = function(args)
        -- args.buf is the current buffer number
        local bufnr = args.buf

        -- map <leader>F to filter the buffer through pg_format -i
        vim.keymap.set("n", "<leader>F", function()
            -- :%   → whole-buffer
            -- !cmd → shell-filter
            vim.cmd("%!pg_format -i")
        end, {
            noremap = true,
            silent  = true,
            buffer  = bufnr,
            desc    = "Format SQL with pg_format",
        })

        -- use the plugin's omni-completion engine:
        vim.opt_local.omnifunc = "vim_dadbod_completion#omni"
        -- override lsp autocomplete only here with omni.
        vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = true, desc = "db-omni" })


        -- change execution to <leader>X
        vim.keymap.del("n", "<leader>S", { buffer = bufnr })
        vim.keymap.set(
            "n",
            "<leader>X",
            "<Plug>(DBUI_ExecuteQuery)",
            { remap = true, buffer = bufnr, desc = "Execute SQL query" }
        )

        -- Paste your default yank into a throwaway buffer and run it through jq
        vim.keymap.set('n', '<leader>jp', function()
            -- Open a brand-new, unlisted scratch buffer
            vim.cmd('enew')
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
            vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
            vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
            vim.api.nvim_set_option_value('filetype', 'json', { buf = buf })

            -- Paste from the unnamed register at the top
            vim.cmd('0put')

            -- Remove the original empty line that was pushed down
            vim.cmd('2delete _')

            -- Run the whole buffer through `jq .`
            vim.cmd('%!jq .')
        end, { desc = 'Open scratch, paste yank, format JSON with jq' })
    end,
})

-- make/clear a group so you can easily remove or tweak it
local dadbod_grp = vim.api.nvim_create_augroup("DadbodUINumbers", { clear = true })

-- listen for the User event named "DBUIOpened"
vim.api.nvim_create_autocmd("User", {
    group = dadbod_grp,
    pattern = "DBUIOpened",
    callback = function()
        -- turn on absolute + relative numbers in that window
        vim.wo.number = true
        vim.wo.relativenumber = true
    end,
})
