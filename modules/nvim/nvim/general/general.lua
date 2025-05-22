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
    { bang = false }
)
