local function bind(op, outer_opts)
    outer_opts = outer_opts or { noremap = true }
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

local nmap = bind("n", { noremap = false })
local nnoremap = bind("n")
local vnoremap = bind("v")
local xnoremap = bind("x")
local inoremap = bind("i")
local tnoremap = bind("t")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 8
vim.opt.colorcolumn = '100'

vim.opt.softtabstop = 4
vim.opt.undodir = '$HOME/.vim/undodir'
vim.opt.undodir = os.getenv("HOME") .. '/.vim/undodir'

vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.listchars = vim.opt.listchars + { space = '·' }
vim.opt.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"

vim.g.mapleader = " "
vim.g.netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

vim.api.nvim_create_user_command(
  'CopyBuffer',
  "let @+ = expand('%')",
  {bang = false}
)

nnoremap("<leader>s", ":update<cr>")
nmap("<leader>bb", "<c-^><cr>")
nmap("<leader>h", ":wincmd h<cr>")
nmap("<leader>l", ":wincmd l<cr>")
nmap("<leader>du", ':DlvTestCurrent --build-flags="-tags=integration,clickhouse -v"<cr>')
nmap("<leader>dc", ":DlvClearAll<cr>")
nmap("<leader>E", ":Explore<cr>")
tnoremap("<Esc>", "<C-\\><C-n>")
nnoremap("<leader>jf", ":%!jq .<cr>")
