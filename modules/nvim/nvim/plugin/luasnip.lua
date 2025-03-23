local ls = require("luasnip")
local NIX_OS_PATH_FRIENDLY_SNIPPET = "$NIX_OS_PATH_PLACEHOLDER_FRIENDLY_SNIPPET";

require("luasnip.loaders.from_vscode").lazy_load({ paths = { NIX_OS_PATH_FRIENDLY_SNIPPET } })

vim.keymap.set({ "i" }, "<C-S>", function() ls.expand() end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })
