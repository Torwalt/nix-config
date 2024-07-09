{ pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/default.nix
    ../../modules/rofi/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix

    ../../modules/wm/hyprland/hyprland.nix
    ../../modules/wm/hyprland/waybar.nix
    ../../modules/wm/hyprland/swaylock.nix
    ../../modules/wm/hyprland/gammastep.nix

    inputs.nix-colors.homeManagerModules.default
  ];

  home = {
    username = "ada";
    homeDirectory = "/home/ada";

    packages = with pkgs; [
      # Monitor config
      nwg-displays
      wlr-randr

      libreoffice
      slack
      google-cloud-sdk
      pgadmin4-desktopmode
    ];

    sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "eDP-1,1920x1200@59.95000,0x0,1.0"
        "DP-3,2560x1440@59.95Hz,2560x0,1.0,bitdepth,10"
      ];
    };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#workSys switch";
    homeswitch = "home-manager switch --flake .#workHome";
  };

  programs.git = { userEmail = lib.mkForce "dadiani@talon.one"; };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  programs.git = {
    extraConfig = {
      url = {
        "ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
      };
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
