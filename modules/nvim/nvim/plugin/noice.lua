pcall(function()
    local notify = require("notify")
    vim.notify = notify
end)

require("noice").setup({
    -- This is the main feature you asked for (cmdline in a centered popup)
    cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            input = { view = "cmdline_input", icon = "󰥻" },
        },
    },

    -- IMPORTANT: you use COQ. Noice can replace the popupmenu UI and that can
    -- conflict with completion plugins. Keep popupmenu OFF.
    popupmenu = {
        enabled = false,
    },

    messages = {
        enabled = true,
        view = "notify", -- uses nvim-notify if available, otherwise falls back
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
    },

    -- Keeps the classic bottom cmdline *only* when Noice can’t attach.
    -- (Also helps with edge cases / weird terminals.)
    health = { checker = true },

    -- Nice LSP markdown rendering without doing anything that breaks Telescope.
    lsp = {
        progress = { enabled = true },
        hover = { enabled = true },
        signature = { enabled = true },
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            -- NOTE: you don't use nvim-cmp, you use COQ, so do NOT enable the cmp override:
            -- ["cmp.entry.get_documentation"] = true,
        },
    },

    -- Some sane noise suppression
    routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "fewer lines" },        opts = { skip = true } },
        { filter = { event = "msg_show", find = "more lines" },         opts = { skip = true } },
        { filter = { event = "msg_show", find = "change;" },            opts = { skip = true } },
    },

    -- The actual cmdline popup layout (centered).
    views = {
        cmdline_popup = {
            border = { style = "rounded", padding = { 0, 1 } },
            position = {
                row = "40%", -- tweak to taste (e.g. "45%")
                col = "50%",
            },
            size = {
                width = 60,
                height = "auto",
            },
            win_options = {
                winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
            },
        },
        popupmenu = {
            -- kept here only so you can enable it later if you switch away from COQ
            backend = "nui",
        },
    },

    presets = {
        bottom_search = true,     -- keep / and ? at the bottom (usually less annoying)
        command_palette = false,  -- you want centered cmdline, not the wide palette layout
        long_message_to_split = true, -- big messages go to a split, not covering your code
        lsp_doc_border = true,
    },
})

-- Telescope integration (does NOT affect Telescope’s normal pickers)
pcall(function()
    require("telescope").load_extension("noice")
    vim.keymap.set("n", "<leader>fn", "<cmd>Telescope noice<cr>", { desc = "Noice: message history" })
end)

-- Optional: quick access to full message history
vim.keymap.set("n", "<leader>nL", "<cmd>Noice last<cr>", { desc = "Noice: last message" })
vim.keymap.set("n", "<leader>nH", "<cmd>Noice history<cr>", { desc = "Noice: message history (split)" })
