vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- themes
    use 'gruvbox-community/gruvbox'
    use 'folke/tokyonight.nvim'

    -- telescope & treesitter
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-treesitter/nvim-treesitter'

    -- language server stuff
    use 'neovim/nvim-lspconfig'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'williamboman/nvim-lsp-installer'
    -- lsp formatting on save
    use "lukas-reineke/lsp-format.nvim"
    -- completer for ls
    use 'ms-jpq/coq_nvim'
    use 'ms-jpq/coq.artifacts'
    -- dlv
    use 'sebdah/vim-delve'

    -- git
    use 'f-person/git-blame.nvim'

    -- misc
    use 'numToStr/Comment.nvim'
    use 'iamcco/markdown-preview.nvim'

end)
