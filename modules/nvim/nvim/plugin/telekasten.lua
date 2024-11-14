local telekasten = require('telekasten')

telekasten.setup({
    home = vim.fn.expand("~/repos/notes/zettelkasten"), -- Put the name of your notes directory here
    plug_into_calendar = true,
    auto_set_filetype = false,
})

-- Launch panel if nothing is typed after <leader>z
nmap("<leader>Z", function() telekasten.panel() end)

-- Most used functions
nmap("<leader>zf", function() telekasten.find_notes() end)
nmap("<leader>zg", function() telekasten.search_notes() end)
nmap("<leader>zd", function() telekasten.goto_today() end)
nmap("<leader>zz", function() telekasten.follow_link() end)
nmap("<leader>zn", function() telekasten.new_note() end)
nmap("<leader>zc", function() telekasten.show_calendar() end)
nmap("<leader>zb", function() telekasten.show_backlinks() end)
nmap("<leader>zI", function() telekasten.insert_img_link() end)
nmap("<leader>zL", function() telekasten.insert_link() end)
