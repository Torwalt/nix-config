local nnoremap = require("torwalt.keymap").nnoremap
local nmap = require("torwalt.keymap").nmap
local tnoremap = require("torwalt.keymap").tnoremap

nnoremap("<leader>s", ":update<cr>")
nmap("<leader>bb", "<c-^><cr>")
nmap("<leader>h", ":wincmd h<cr>")
nmap("<leader>l", ":wincmd l<cr>")
nmap("<leader>du", ":DlvTestCurrent<cr>")
nmap("<leader>dc", ":DlvClearAll<cr>")

tnoremap("<Esc>", "<C-\\><C-n>")
