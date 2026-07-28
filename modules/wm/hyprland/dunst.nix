{ config, lib, ... }:

let
  cfg = config.wm.hyprland;
in
{
  services.dunst = {
    enable = true;

    settings.global = {
      follow = "none";
      origin = "top-right";
    };
  };

  services.dunst.settings.global.monitor = lib.mkIf (
    cfg.notification.monitor != null
  ) cfg.notification.monitor;

  systemd.user.services.dunst = {
    Unit = {
      After = lib.mkForce [ cfg.sessionTarget ];
      PartOf = lib.mkForce [ cfg.sessionTarget ];
    };

    Service.Restart = "on-failure";

    Install.WantedBy = [ cfg.sessionTarget ];
  };
}
