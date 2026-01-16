-- /nix/store/.../modules/nvim/nvim/plugin/nvim-cmp.lua
--
-- Drop-in replacement for COQ.
-- You should REMOVE/DISABLE your coq_nvim.lua (the `require('coq')` + `COQnow -s` bits),
-- and ensure these plugins are installed (via Nix):
--
--   hrsh7th/nvim-cmp
--   hrsh7th/cmp-nvim-lsp
--   hrsh7th/cmp-buffer
--   hrsh7th/cmp-path
--   hrsh7th/cmp-cmdline
--   L3MON4D3/LuaSnip
--   saadparwaiz1/cmp_luasnip
--   (optional but nice) onsails/lspkind.nvim   -- icons in completion menu
--
-- You already have LuaSnip + friendly-snippets configured; this will reuse that.
--
-- IMPORTANT with your setup:
-- - This config aggressively prioritizes LSP completion over buffer words
--   to avoid the “random tmux word beats struct field” annoyance.
-- - It does NOT depend on noice popupmenu integration (keeps your noice.popupmenu disabled).

local cmp = require("cmp")
local luasnip = require("luasnip")

-- Optional: pretty icons. Works without it.
local has_lspkind, lspkind = pcall(require, "lspkind")

-- If you want completion to feel "typed language first", keep keyword_length > 1 for buffer.
-- That way buffer junk won't spam you instantly.
local BUFFER_KEYWORD_LEN = 3

cmp.setup({
    enabled = function()
        -- Disable in prompt-like buffers (Telescope prompt, etc.)
        local bt = vim.api.nvim_get_option_value("buftype", { buf = 0 })
        if bt == "prompt" then
            return false
        end
        return true
    end,

    completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged },
        completeopt = "menu,menuone,noselect",
    },

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        -- Manual trigger like COQ users expect
        ["<C-Space>"] = cmp.mapping.complete(),

        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirm selection
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        -- Navigate items
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

        -- Scroll docs
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),

        -- Tab: if menu open -> next; else if snippet jumpable -> jump; else fallback
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    -- Sources are ordered by priority (top wins).
    -- This is the main fix for your complaint: LSP wins, buffer is "last resort".
    sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip",  priority = 750 },
        { name = "path",     priority = 500 },
        { name = "buffer",   priority = 250, keyword_length = BUFFER_KEYWORD_LEN, max_item_count = 5 },
    }),

    sorting = {
        -- Make sorting stable and LSP-first.
        priority_weight = 2,
        comparators = {
            -- Prefer exact matches first (e.g. typing ".A" should prefer "Age" over random)
            cmp.config.compare.exact,
            -- Prefer items closer to cursor prefix
            cmp.config.compare.score,
            -- Prefer recently used items (but only after score/exact)
            cmp.config.compare.recently_used,
            -- Prefer local scope
            cmp.config.compare.locality,
            -- Prefer shorter
            cmp.config.compare.length,
            -- Finally keep original order
            cmp.config.compare.order,
        },
    },

    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
            if has_lspkind then
                item.kind = lspkind.symbolic(item.kind, { mode = "symbol" })
            end

            local menus = {
                nvim_lsp = "[LSP]",
                luasnip  = "[Snip]",
                path     = "[Path]",
                buffer   = "[Buf]",
            }
            item.menu = menus[entry.source.name] or ("[" .. entry.source.name .. "]")
            return item
        end,
    },

    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    experimental = {
        ghost_text = false, -- COQ-like inline ghost text; turn on if you want
    },
})

-- Cmdline completion (optional but nice)
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

-- LSP capabilities:
-- You MUST feed these to your LSP configs, otherwise you lose completion richness.
--
-- You already have a central place:
--   /modules/nvim/nvim/plugin/lspconfigs/common.lua
--
-- Add this exact snippet there (or just paste it anywhere that runs before servers are enabled):
--
--   local caps = require("cmp_nvim_lsp").default_capabilities()
--   vim.lsp.config('*', {
--     on_attach = on_attach,
--     capabilities = caps,
--   })
--
-- For servers where you override vim.lsp.config('name', { ... }), also merge caps into that config.
-- Example:
--   local caps = require("cmp_nvim_lsp").default_capabilities()
--   vim.lsp.config('gopls', { capabilities = caps, on_attach = go_on_attach, ... })
--
-- If you *don't* do this, completion still works, but worse (less detail, fewer kinds/snippets).
