{ pkgs, inputs, pkgs-unstable, ... }: {
  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          neotest-golang-nvim = prev.vimUtils.buildVimPlugin {
            name = "neotest-golang-nvim";
            src = inputs.plugin-neotest-golang-nvim;
          };
        };
      })
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          telescope-emoji-nvim = prev.vimUtils.buildVimPlugin {
            name = "telescope-emoji-nvim";
            src = inputs.plugin-telescope-emoji-nvim;
          };
        };
      })
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          telescope-luasnip-nvim = prev.vimUtils.buildVimPlugin {
            name = "telescope-luasnip-nvim";
            src = inputs.plugin-telescope-luasnip-nvim;
          };
        };
      })
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    packages = [ pkgs.ripgrep pkgs-unstable.gopls pkgs.sqls pkgs.prettierd ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = let
      fileUtils = import ../lib/fileutils.nix;
      patterns = [ "$NIX_OS_PATH_PLACEHOLDER_FRIENDLY_SNIPPET" ];
      replacements = [ "${pkgs.vimPlugins.friendly-snippets}" ];

      configContent = fileUtils.readNeovimConfig ./nvim [ "lib" "general" "plugin" ];

      replaced = builtins.replaceStrings patterns replacements configContent;
    in replaced;

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      plenary-nvim
      telescope-nvim
      telescope-live-grep-args-nvim
      nvim-lspconfig
      lsp-format-nvim
      coq_nvim
      coq-artifacts
      git-blame-nvim
      comment-nvim
      markdown-preview-nvim
      telekasten-nvim
      telescope-media-files-nvim
      calendar-vim
      text-case-nvim

      luasnip
      friendly-snippets

      # ✨ AI ✨
      avante-nvim
      # deps for avante
      dressing-nvim
      nui-nvim

      # language specific
      rustaceanvim

      # testing
      nvim-nio
      neotest
      FixCursorHold-nvim

      # debugging
      nvim-dap
      nvim-dap-go

      # From overlay
      neotest-golang-nvim
      telescope-emoji-nvim
      telescope-luasnip-nvim

      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-parsers.astro
    ];

    extraPackages = with pkgs; [
      nil
      lua-language-server
      python3
      yaml-language-server
      chafa
      typescript-language-server
      pyright
      vscode-langservers-extracted
      efm-langserver
      astro-language-server
    ];
  };
}
