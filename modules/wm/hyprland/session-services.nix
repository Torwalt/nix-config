{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wm.hyprland;

  waylandSocketReady = pkgs.writeShellScript "wayland-socket-ready" ''
    test -n "$WAYLAND_DISPLAY"
    test -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
  '';

  wallpaperScript = pkgs.writeShellScript "awww-wallpaper" ''
    for attempt in $(seq 1 20); do
      if ${pkgs.awww}/bin/awww img ${lib.escapeShellArg cfg.wallpaper}; then
        exit 0
      fi

      sleep 0.2
    done

    exit 1
  '';
in
{
  config = {
    systemd.user.services = {
      nm-applet = {
        Unit = {
          Description = "NetworkManager applet";
          PartOf = [ cfg.sessionTarget ];
          After = [ cfg.sessionTarget ];
        };

        Service = {
          ExecCondition = waylandSocketReady;
          ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
          Restart = "on-failure";
          RestartSec = 2;
        };

        Install.WantedBy = [ cfg.sessionTarget ];
      };

      awww = {
        Unit = {
          Description = "awww wallpaper daemon";
          PartOf = [ cfg.sessionTarget ];
          After = [ cfg.sessionTarget ];
        };

        Service = {
          ExecCondition = waylandSocketReady;
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
          Restart = "on-failure";
          RestartSec = 2;
        };

        Install.WantedBy = [ cfg.sessionTarget ];
      };

      awww-wallpaper = {
        Unit = {
          Description = "Apply Hyprland wallpaper";
          Requires = [ "awww.service" ];
          After = [
            cfg.sessionTarget
            "awww.service"
          ];
          PartOf = [ cfg.sessionTarget ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = wallpaperScript;
        };

        Install.WantedBy = [ cfg.sessionTarget ];
      };

      maestral-gui = {
        Unit = {
          Description = "Maestral GUI";
          PartOf = [ cfg.sessionTarget ];
          After = [ cfg.sessionTarget ];
        };

        Service = {
          ExecCondition = waylandSocketReady;
          ExecStart = "${pkgs.maestral-gui}/bin/maestral_qt";
          Restart = "on-failure";
          RestartSec = 2;
        };

        Install.WantedBy = [ cfg.sessionTarget ];
      };
    };
  };
}
