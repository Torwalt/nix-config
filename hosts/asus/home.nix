{
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}:

let
  unstable = with pkgs-unstable; [ codex ];
in
{
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
    ../../modules/maintenance/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix
    ../../modules/go/default.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix
    ../../modules/shell/ssh.nix

    ../../modules/wm/hyprland
    ../../modules/ai/default.nix

    inputs.nix-colors.homeManagerModules.default
  ];

  home.packages =
    with pkgs;
    [
      brightnessctl
      telegram-desktop
    ]
    ++ unstable;

  wm.hyprland.notification.monitor = "HDMI-A-1";

  wayland.windowManager.hyprland.settings.bindle = [
    ", F3, exec, ${pkgs.brightnessctl}/bin/brightnessctl --device='*::kbd_backlight' set 1-"
    ", F4, exec, ${pkgs.brightnessctl}/bin/brightnessctl --device='*::kbd_backlight' set 1+"
    ", F5, exec, ${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 5%-"
    ", F6, exec, ${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 5%+"
    ", F10, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", F12, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
  ];

  home = {
    username = "ada";
    homeDirectory = "/home/ada";
  };

  programs.nixup = {
    enable = true;
    systemConfiguration = "asusSys";
    homeConfiguration = "asusHome";
  };
}
