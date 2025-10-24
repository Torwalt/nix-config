{ pkgs, inputs, ... }: {
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/home.nix
    ../../modules/stylix/default.nix
    ../../modules/rofi/default.nix
    ../../modules/nap/default.nix
    ../../modules/direnv/default.nix
    ../../modules/delve/default.nix
    ../../modules/lazydocker/default.nix
    ../../modules/timewarrior/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix
    ../../modules/go/default.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix
    ../../modules/shell/ssh.nix

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
