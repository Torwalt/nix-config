{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          vim-delve-nvim = prev.vimUtils.buildVimPlugin {
            name = "vim-delve";
            src = inputs.plugin-vim-delve;
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
    username = "ada";
    homeDirectory = "/home/ada";

    packages = [
        pkgs.gcc
        pkgs.go
        pkgs.jq
        pkgs.keepassxc
        pkgs.python3
        pkgs.zsh-vi-mode
        pkgs.ripgrep
        pkgs.delve
        pkgs.gnumake
    ];

    sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;


    extraLuaConfig = ''
        ${builtins.readFile ../nvim/init.lua}
        ${builtins.readFile ../nvim/plugin/color.lua}
        ${builtins.readFile ../nvim/plugin/comment.lua}
        ${builtins.readFile ../nvim/plugin/coq_nvim.lua}
        ${builtins.readFile ../nvim/plugin/null-ls.lua}
        ${builtins.readFile ../nvim/plugin/nvim-treesitter.lua}
        ${builtins.readFile ../nvim/plugin/telescope.lua}
        ${builtins.readFile ../nvim/plugin/nvim-lspconfig.lua}
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

    extraPackages = with pkgs; [
        nil
        luajitPackages.lua-lsp
        python3
        gopls
    ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";
  };

    # In order for .profile being updated.
    programs.bash = {
      enable = true;
    };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    defaultKeymap = "viins";

    shellAliases = {
        gs = "git status";
        gg = "git checkout";
        ga = "git commit --amend";
        v = "nvim";
        update = "home-manager switch --flake ~/nix-config/#ada@ada-machine";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "jeffreytse/zsh-vi-mode"; }
        { name = "plugins/git"; tags = [ "from:oh-my-zsh" ]; }
      ];
    };

    plugins = [
        {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
    ];

    initExtra = ''
        source ~/nix-config/.p10k.zsh
        '';
  };

    programs.tmux = {
        enable = true;
        escapeTime = 0;
        terminal = "screen-256color";
        historyLimit = 100000;
        keyMode = "vi";

        plugins = with pkgs;
        [
            tmuxPlugins.sensible
            tmuxPlugins.resurrect
            tmuxPlugins.yank
        ];
    };

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
