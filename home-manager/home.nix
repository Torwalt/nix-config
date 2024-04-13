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
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;

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

    oh-my-zsh = {
        enable = true;
        plugins = [
                "git"
                "zsh-vi-mode"
                ];
        theme = "sunaku";
    };
  };

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
