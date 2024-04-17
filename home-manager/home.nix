{ pkgs, inputs, ... }:

{
  imports = [
    ../modules/nvim/nvim.nix

    ../modules/cli/all.nix

    ../modules/shell/shell.nix
    ../modules/shell/tmux.nix

    ../modules/wm/hyprland/hyprland.nix
    ../modules/wm/hyprland/waybar.nix
    ../modules/wm/hyprland/swaylock.nix
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

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  home = {
    username = "ada";
    homeDirectory = "/home/ada";

    packages = with pkgs; [
      gcc
      go
      jq
      keepassxc
      python3
      zsh-vi-mode
      ripgrep
      delve
      gnumake
      nixfmt
      firefox
      pavucontrol
      telegram-desktop

      # Fonts
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      nerdfonts
      noto-fonts
      noto-fonts-emoji
      proggyfonts
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
