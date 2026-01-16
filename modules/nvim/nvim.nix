{ pkgs, inputs, pkgs-unstable, ... }: {
  nixpkgs = {
    overlays = [
      inputs.nvim-treesitter-main.overlays.default

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
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          neotest-golang-nvim = prev.vimUtils.buildVimPlugin {
            name = "neotest-golang-nvim";
            src = inputs.plugin-neotest-golang-nvim;
            doCheck = false;
          };
        };
      })
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          nvim-treesitter-textobjects = prev.vimUtils.buildVimPlugin {
            name = "nvim-treesitter-textobjects";
            src = inputs.plugin-nvim-treesitter-textobjects;
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
    packages =
      [ pkgs.ripgrep pkgs-unstable.gopls pkgs.sqls pkgs.prettierd pkgs.fd ];

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

      configContent =
        fileUtils.readNeovimConfig ./nvim [ "lib" "general" "plugin" ];

      replaced = builtins.replaceStrings patterns replacements configContent;
    in replaced;

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      git-blame-nvim
      comment-nvim
      markdown-preview-nvim
      telekasten-nvim
      calendar-vim
      text-case-nvim
      nvim-surround

      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      lspkind-nvim

      noice-nvim
      nui-nvim
      nvim-notify

      luasnip
      friendly-snippets

      nvim-lspconfig
      lsp-format-nvim

      plenary-nvim
      telescope-nvim
      telescope-media-files-nvim
      telescope-live-grep-args-nvim
      telescope-emoji-nvim
      telescope-luasnip-nvim
      telescope-fzf-native-nvim

      rustaceanvim

      # testing
      nvim-nio
      neotest
      FixCursorHold-nvim
      nvim-dap
      nvim-dap-go
      neotest-golang-nvim

      nvim-treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-textobjects

      # db
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
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
