{ pkgs, inputs, ... }:

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
    ];

    sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
  };

  wayland.windowManager.hyprland = {
    settings = {
      # monitor = [
      #   "DP-1,2560x1440@59.951,0x0,1.0,bitdepth,10"
      #   "HDMI-A-3,2560x1440@99.945999,2560x0,1.0,bitdepth,10"
      #   "Unknown-1,disabled"
      # ];
    };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#workSys switch";
    homeswitch = "home-manager switch --flake .#workHome";
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
