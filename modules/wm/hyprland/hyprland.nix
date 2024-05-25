{ pkgs, ... }:

let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &

    ${pkgs.waybar}/bin/waybar &

    ${pkgs.dunst}/bin/dunst
  '';
in {
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {

      monitor = [ ",preferred,auto,auto" ];

      env = "XCURSOR_SIZE,24";

      input = {
        kb_layout = "de";
        kb_options = "caps:swapescape";
        follow_mouse = 1;
        touchpad = { natural_scroll = "no"; };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        layout = "dwindle";
        allow_tearing = false;
      };

      windowrulev2 = [
        "opacity 0.9 0.8,class:.*" # Set opacity of active and inactive windows for all types of windows.
      ];

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      master = { new_is_master = true; };

      gestures = { workspace_swipe = "off"; };

      misc = {
        force_default_wallpaper = 0;
      };

      "$mainMod" = "ALT_L";

      bind = [
        # Program shortcuts
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, Q, killactive, "
        "$mainMod, X, exit, "
        "$mainMod, D, exec, rofi -show drun -show-icons"
        "$mainMod, L, exec, swaylock"

        # Screenshotting
        "$mainMod SHIFT, P, exec, wl-paste | swappy -f - "
        ''$mainMod SHIFT, S, exec, grim -g "$(slurp)" -  | wl-copy''

        # Window manipulation"
        "$mainMod, V, togglefloating, "
        "$mainMod, T, togglegroup, "
        "$mainMod, N, changegroupactive, "
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo, # dwindle"
        # Move focus with mainMod + arrow keys
        "$mainMod, l, movefocus, l"
        "$mainMod, r, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        # Spotify controls
        "$mainMod SHIFT, N, exec, dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
        "$mainMod SHIFT, P, exec, dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      exec-once = [
        "${startupScript}/bin/start"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
    };
  };
}
