{ lib, ... }:

{
  imports = [
    ./hyprland.nix
    ./session-services.nix
    ./dunst.nix
    ./waybar.nix
    ./swaylock.nix
    ./gammastep.nix
  ];

  options.wm.hyprland = {
    sessionTarget = lib.mkOption {
      type = lib.types.str;
      default = "hyprland-session.target";
      description = "systemd user target managed by Home Manager's Hyprland session integration.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../../wp.png;
      description = "Wallpaper image applied after the awww daemon is available.";
    };

    notification.monitor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional monitor name for Dunst notifications.";
    };
  };
}
