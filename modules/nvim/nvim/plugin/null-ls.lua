require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.black,
        require("null-ls").builtins.diagnostics.flake8,
        require("null-ls").builtins.formatting.nixfmt,
        require("null-ls").builtins.formatting.rustfmt,
        require("null-ls").builtins.formatting.lua_format,
        require("null-ls").builtins.formatting.pg_format
    }
})
