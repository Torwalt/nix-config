{ pkgs, inputs, lib, ... }:

let homeDirectory = "/home/ada";
in {
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/default.nix
    ../../modules/stylix/home.nix
    ../../modules/rofi/default.nix
    ../../modules/nap/default.nix
    ../../modules/python/default.nix
    ../../modules/direnv/default.nix
    ../../modules/delve/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix
    ../../modules/shell/ssh.nix

    ../../modules/wm/hyprland/hyprland.nix
    ../../modules/wm/hyprland/waybar.nix
    ../../modules/wm/hyprland/swaylock.nix
    ../../modules/wm/hyprland/gammastep.nix

    inputs.nix-colors.homeManagerModules.default
  ];

  home = {
    username = "ada";
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # Monitor config
      nwg-displays
      wlr-randr

      libreoffice
      go-task
    ];

    sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#workSys switch";
    homeswitch = "home-manager switch --flake .#workHome";
  };

  programs.git = { userEmail = lib.mkForce "alexdadiani1994@gmail.com"; };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
