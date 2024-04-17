{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./nvim/init.lua}
      ${builtins.readFile ./nvim/plugin/color.lua}
      ${builtins.readFile ./nvim/plugin/comment.lua}
      ${builtins.readFile ./nvim/plugin/coq_nvim.lua}
      ${builtins.readFile ./nvim/plugin/null-ls.lua}
      ${builtins.readFile ./nvim/plugin/nvim-treesitter.lua}
      ${builtins.readFile ./nvim/plugin/telescope.lua}
      ${builtins.readFile ./nvim/plugin/nvim-lspconfig.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      plenary-nvim
      telescope-nvim
      nvim-lspconfig
      null-ls-nvim
      lsp-format-nvim
      coq_nvim
      coq-artifacts
      git-blame-nvim
      comment-nvim
      markdown-preview-nvim
      vim-delve-nvim

      nvim-treesitter.withAllGrammars
    ];

    extraPackages = with pkgs; [ nil luajitPackages.lua-lsp python3 gopls ];
  };
}
