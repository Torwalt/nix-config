require('telekasten').setup({
  home = vim.fn.expand("~/repos/notes/zettelkasten"), -- Put the name of your notes directory here
  plug_into_calendar = true,
})

-- Launch panel if nothing is typed after <leader>z
NMap("<leader>z", [[<cmd>Telekasten panel<CR>]])

-- Most used functions
NMap("<leader>zf", [[<cmd>Telekasten find_notes<CR>]])
NMap("<leader>zg", [[<cmd>Telekasten search_notes<CR>]])
NMap("<leader>zd", [[<cmd>Telekasten goto_today<CR>]])
NMap("<leader>zz", [[<cmd>Telekasten follow_link<CR>]])
NMap("<leader>zn", [[<cmd>Telekasten new_note<CR>]])
NMap("<leader>zc", [[<cmd>Telekasten show_calendar<CR>]])
NMap("<leader>zb", [[<cmd>Telekasten show_backlinks<CR>]])
NMap("<leader>zI", [[<cmd>Telekasten insert_img_link<CR>]])
NMap("<leader>zL", [[<cmd>Telekasten insert_link<CR>]])

