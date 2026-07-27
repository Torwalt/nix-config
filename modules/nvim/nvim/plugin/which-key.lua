local which_key = require("which-key")

which_key.setup({
    delay = 1000,
})

which_key.add({
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" },
    { "<leader>f", group = "find" },
    { "<leader>j", group = "json/window" },
    { "<leader>n", group = "notifications" },
    { "<leader>r", group = "review" },
    { "<leader>w", group = "workspace" },
    { "<leader>z", group = "notes/window" },
})
