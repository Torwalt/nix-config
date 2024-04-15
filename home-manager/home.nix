{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
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
        { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
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
