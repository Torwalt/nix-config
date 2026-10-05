{ config, lib, ... }:

let
  cfg = config.wm.hyprland;
  swayncClient = "${config.services.swaync.package}/bin/swaync-client";

  bell = "";
  bellSlash = "";
in
{
  services.swaync = {
    enable = true;

    settings = {
      timeout = 10;
      hide-on-clear = true;
      notification-grouping = false;
    }
    // lib.optionalAttrs (cfg.notification.monitor != null) {
      notification-window-preferred-output = cfg.notification.monitor;
      control-center-preferred-output = cfg.notification.monitor;
    };
  };

  systemd.user.services.swaync = {
    Unit = {
      After = lib.mkForce [ cfg.sessionTarget ];
      PartOf = lib.mkForce [ cfg.sessionTarget ];
    };

    Install.WantedBy = lib.mkForce [ cfg.sessionTarget ];
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, Y, exec, ${swayncClient} -t -sw"
    "$mainMod SHIFT, Y, exec, ${swayncClient} -C -sw"
  ];

  programs.waybar.settings.mainBar = {
    modules-right = lib.mkAfter [ "custom/notification" ];
    "custom/notification" = {
      exec = "${swayncClient} -swb";
      return-type = "json";
      format = "{} {icon}";
      format-icons = {
        default = bell;
      }
      // lib.genAttrs [
        "dnd-none"
        "dnd-notification"
        "dnd-inhibited-none"
        "dnd-inhibited-notification"
      ] (_: bellSlash);
      on-click = "${swayncClient} -t -sw";
      on-click-right = "${swayncClient} -C -sw";
    };
  };

  programs.waybar.style = lib.mkAfter ''
    #custom-notification {
      padding: 0 5px;
    }

    #custom-notification.notification {
      color: @base0A;
    }
  '';
}
