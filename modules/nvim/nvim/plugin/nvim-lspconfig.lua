local util = require "lspconfig/util"

local on_attach = function(_, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
                   opts)
    buf_set_keymap('n', '<leader>wa',
                   '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr',
                   '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl',
                   '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                   opts)
    buf_set_keymap('n', '<leader>D',
                   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                   opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>',
                   opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>',
                   opts)
    buf_set_keymap('n', '<leader>F',
                   '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
end

local lspconfig = require("lspconfig")

vim.lsp.set_log_level("debug")

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    cmd = {"lua-lsp"},
    settings = {
        Lua = {
            workspace = {checkThirdParty = false},
            telemetry = {enable = false}
        }
    }
}

require("lsp-format").setup {}

local go_on_attach = function(client, bufnr)
    require"lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

lspconfig.gopls.setup {
    on_attach = go_on_attach,
    init_options = {buildFlags = {"-tags=clickhouse,integration"}}
}

lspconfig.solargraph.setup {
    on_attach = on_attach,
    settings = {
        solargraph = {
            autoformat = false,
            formatting = false,
            completion = true,
            diagnostic = true,
            folding = true,
            references = true,
            rename = true,
            symbols = true
        }
    }
}

lspconfig.intelephense.setup {on_attach = on_attach}

lspconfig.jdtls.setup {on_attach = on_attach}

lspconfig.terraformls.setup {on_attach = on_attach}
lspconfig.yamlls.setup {on_attach = on_attach}
lspconfig.jsonls.setup {on_attach = on_attach}
lspconfig.eslint.setup {on_attach = on_attach}
lspconfig.nil_ls.setup {on_attach = on_attach}

local sqls_on_attach = function(client, bufnr)
    require"lsp-format".on_attach(client)
    on_attach(client, bufnr)
    require('sqls').on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

-- lspconfig.sqls.setup {
--     cmd = {
--         "/home/ada/.nix-profile/bin/sqls", "-config",
--         "~/.config/sqls/config.yml"
--     },
--     on_attach = sqls_on_attach
-- }

local rust_on_attach = function(client, bufnr)
    require"lsp-format".on_attach(client)
    on_attach(client, bufnr)
end

lspconfig.rust_analyzer.setup {
    on_attach = rust_on_attach,
    capabilities = capabilities,
    filetypes = {"rust"},
    root_dir = util.root_pattern("Cargo.toml"),
    settings = {
        ["rust-analyzer"] = {cargo = {allFeatures = true}},
        diagnostics = {enable = true}
    }
}
