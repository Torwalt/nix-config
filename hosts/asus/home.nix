{ pkgs, ... }: {
  imports = [
    ../../modules/base.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix

    ../../modules/wm/hyprland/hyprland.nix
    ../../modules/wm/hyprland/waybar.nix
    ../../modules/wm/hyprland/swaylock.nix
  ];

  home.packages = with pkgs; [ telegram-desktop ];

  home = {
    username = "ada";
    homeDirectory = "/home/ada";
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#asusHome switch";
    homeswitch = "home-manager switch --flake .#asusHome";
  };
}
