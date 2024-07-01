{ pkgs, inputs, ... }: {
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

  home.packages = with pkgs; [ telegram-desktop ];

  home = {
    username = "ada";
    homeDirectory = "/home/ada";
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#asusSys switch";
    homeswitch = "home-manager switch --flake .#asusHome";
  };
}
