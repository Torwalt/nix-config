{
  config,
  lib,
  pkgs,
  ...
}:

let
  germanInputMethod = "keyboard-de";
  russianInputMethod = "m17n_ru_translit";

  fcitx5 = pkgs.qt6Packages.fcitx5-with-addons.override {
    addons = [ pkgs.fcitx5-m17n ];
  };

  toggleInputMethod = pkgs.writeShellApplication {
    name = "toggle-input-method";
    runtimeInputs = [
      fcitx5
      pkgs.procps
    ];
    text = ''
      current="$(fcitx5-remote -n 2>/dev/null || true)"

      if [ "$current" = "${russianInputMethod}" ]; then
        fcitx5-remote -s "${germanInputMethod}"
      else
        fcitx5-remote -s "${russianInputMethod}"
      fi

      pkill -RTMIN+8 waybar || true
    '';
  };

  inputMethodStatus = pkgs.writeShellApplication {
    name = "input-method-status";
    runtimeInputs = [ fcitx5 ];
    text = ''
      state="$(fcitx5-remote 2>/dev/null || true)"

      case "$state" in
        1)
          printf '{"text":"  DE","tooltip":"German keyboard (Alt+Space to switch)","class":"german"}\n'
          ;;
        2)
          method="$(fcitx5-remote -n 2>/dev/null || true)"
          if [ "$method" = "${russianInputMethod}" ]; then
            printf '{"text":"Я  RU","tooltip":"Russian transliteration (Alt+Space to switch)","class":"russian"}\n'
          else
            printf '{"text":"  IM","tooltip":"Input method: %s","class":"active"}\n' "$method"
          fi
          ;;
        *)
          printf '{"text":"  --","tooltip":"Fcitx 5 is not running","class":"offline"}\n'
          ;;
      esac
    '';
  };
in
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

  config = {
    home.packages = [ fcitx5 ];

    xdg.configFile."fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        # Group Name
        Name=German and Russian translit
        # Layout
        Default Layout=de
        # Default Input Method
        DefaultIM=${germanInputMethod}

        [Groups/0/Items/0]
        # Name
        Name=${germanInputMethod}
        # Layout
        Layout=de

        [Groups/0/Items/1]
        # Name
        Name=${russianInputMethod}
        # Layout
        Layout=de

        [GroupOrder]
        0=German and Russian translit
      '';
    };

    systemd.user.services.fcitx5 = {
      Unit = {
        Description = "Fcitx 5 input method";
        PartOf = [ config.wm.hyprland.sessionTarget ];
        After = [ config.wm.hyprland.sessionTarget ];
      };

      Service = {
        ExecStart = "${fcitx5}/bin/fcitx5 --replace";
        Restart = "on-failure";
      };

      Install.WantedBy = [ config.wm.hyprland.sessionTarget ];
    };

    wayland.windowManager.hyprland.settings.bind = [
      "$mainMod, SPACE, exec, ${toggleInputMethod}/bin/toggle-input-method"
    ];

    programs.waybar.settings.mainBar = {
      modules-right = lib.mkBefore [ "custom/input-method" ];
      "custom/input-method" = {
        exec = "${inputMethodStatus}/bin/input-method-status";
        return-type = "json";
        interval = 2;
        signal = 8;
        on-click = "${toggleInputMethod}/bin/toggle-input-method";
      };
    };

    programs.waybar.style = lib.mkAfter ''
      #custom-input-method {
        padding: 0 5px;
      }

      #custom-input-method.russian {
        color: @base0E;
      }

      #custom-input-method.offline {
        color: @base08;
      }
    '';
  };
}
