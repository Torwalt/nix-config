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
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    packages = [ pkgs.ripgrep pkgs-unstable.gopls pkgs.sqls ];

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

    extraLuaConfig = ''
      ${builtins.readFile ./nvim/init.lua}
      ${builtins.readFile ./nvim/plugin/map.lua}
      ${builtins.readFile ./nvim/plugin/remap.lua}
      ${builtins.readFile ./nvim/plugin/color.lua}
      ${builtins.readFile ./nvim/plugin/comment.lua}
      ${builtins.readFile ./nvim/plugin/coq_nvim.lua}
      ${builtins.readFile ./nvim/plugin/nvim-treesitter.lua}
      ${builtins.readFile ./nvim/plugin/telescope.lua}
      ${builtins.readFile ./nvim/plugin/nvim-lspconfig.lua}
      ${builtins.readFile ./nvim/plugin/telekasten.lua}
      ${builtins.readFile ./nvim/plugin/telescope-media-files.lua}
      ${builtins.readFile ./nvim/plugin/dap.lua}
      ${builtins.readFile ./nvim/plugin/neotest.lua}
      ${builtins.readFile ./nvim/plugin/ft-rules.lua}
      ${builtins.readFile ./nvim/plugin/gitblame.lua}
      ${builtins.readFile ./nvim/plugin/avante.lua}
    '';

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

      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
    ];

    extraPackages = with pkgs; [
      nil
      luajitPackages.lua-lsp
      python3
      yaml-language-server
      chafa
      typescript-language-server
      pyright
      vscode-langservers-extracted
    ];
  };
}
