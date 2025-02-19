local telekasten = require('telekasten')

telekasten.setup({
    home = vim.fn.expand("~/repos/notes/zettelkasten"), -- Put the name of your notes directory here
    plug_into_calendar = true,
    auto_set_filetype = false,
})

-- Launch panel if nothing is typed after <leader>z
nmap("<leader>Z", function() telekasten.panel() end)

