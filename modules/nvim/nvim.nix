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
    package = pkgs-unstable.neovim-unwrapped;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = let
      fileUtils = import ../lib/fileutils.nix;
      # lib must be before plugin
    in fileUtils.readNeovimConfig ./nvim [ "lib" "plugin" ];

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
