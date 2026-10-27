{
  config,
  lib,
  pkgs,
  ...
}:

let
  signal = 9;

  toggleTailscale = pkgs.writeShellApplication {
    name = "toggle-tailscale";
    runtimeInputs = [
      pkgs.procps
      pkgs.systemd
    ];
    text = ''
      if systemctl is-active --quiet tailscaled.service; then
        systemctl stop tailscaled.service
      else
        systemctl start tailscaled.service
      fi

      pkill -RTMIN+${toString signal} waybar || true
    '';
  };

  tailscaleStatus = pkgs.writeShellApplication {
    name = "tailscale-status";
    runtimeInputs = [
      pkgs.jq
      pkgs.systemd
      pkgs.tailscale
    ];
    text = ''
      if ! systemctl is-active --quiet tailscaled.service; then
        printf '{"text":"󰖂 off","tooltip":"Tailscale stopped (Alt+Shift+T to join)","class":"off"}\n'
        exit 0
      fi

      if ! status="$(tailscale status --json 2>/dev/null)"; then
        printf '{"text":"󰖂 …","tooltip":"tailscaled is starting","class":"starting"}\n'
        exit 0
      fi

      jq -c '
        if .BackendState == "Running" then
          {text: "󰖂 TS", class: "on",
           tooltip: "Joined \(.CurrentTailnet.Name) as \(.Self.TailscaleIPs[0]) (Alt+Shift+T to leave)"}
        elif .BackendState == "Starting" then
          {text: "󰖂 …", class: "starting", tooltip: "Connecting to the tailnet"}
        else
          {text: "󰖂 \(.BackendState)", class: "attention",
           tooltip: "tailscaled runs but is \(.BackendState): run tailscale up"}
        end
      ' <<<"$status"
    '';
  };
in
{
  config = lib.mkIf config.wm.hyprland.tailscale.enable {
    wayland.windowManager.hyprland.settings.bind = [
      "$mainMod SHIFT, T, exec, ${toggleTailscale}/bin/toggle-tailscale"
    ];

    programs.waybar.settings.mainBar = {
      modules-right = lib.mkBefore [ "custom/tailscale" ];
      "custom/tailscale" = {
        exec = "${tailscaleStatus}/bin/tailscale-status";
        return-type = "json";
        interval = 2;
        inherit signal;
        on-click = "${toggleTailscale}/bin/toggle-tailscale";
      };
    };

    programs.waybar.style = lib.mkAfter ''
      #custom-tailscale {
        padding: 0 5px;
      }

      #custom-tailscale.on {
        color: @base0B;
      }

      #custom-tailscale.off {
        color: @base03;
      }

      #custom-tailscale.starting,
      #custom-tailscale.attention {
        color: @base0A;
      }
    '';
  };
}
