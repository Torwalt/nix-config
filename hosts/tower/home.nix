{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/default.nix
    ../../modules/stylix/home.nix
    ../../modules/rofi/default.nix
    ../../modules/nap/default.nix
    ../../modules/direnv/default.nix
    ../../modules/delve/default.nix
    ../../modules/lazydocker/default.nix
    ../../modules/timewarrior/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix
    ../../modules/go/default.nix

    ../../modules/gaming/default.nix

    ../../modules/shell/shell.nix
    ../../modules/shell/tmux.nix
    ../../modules/shell/ssh.nix

    ../../modules/wm/hyprland/hyprland.nix
    ../../modules/wm/hyprland/waybar.nix
    ../../modules/wm/hyprland/swaylock.nix
    ../../modules/wm/hyprland/gammastep.nix

    inputs.nix-colors.homeManagerModules.default
  ];

  home = {
    username = "ada";
    homeDirectory = "/home/ada";

    packages = with pkgs; [
      # Monitor config
      nwg-displays
      wlr-randr

      libreoffice
      gimp-with-plugins

      # Non programming
      telegram-desktop
      discord
      libresprite
      renderdoc
      helvum
      gzdoom
      lutris
    ];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = 1;
      CLUTTER_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_DRM_NO_ATOMIC = "1";
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor =
        [ "DP-1,2560x1440@59.95,0x0,1" "HDMI-A-3,2560x1440@60,2560x0,1" ];

      workspace = [
        "1, monitor:HDMI-A-3"
        "3, monitor:HDMI-A-3"
        "4, monitor:HDMI-A-3"
        "5, monitor:HDMI-A-3"
        "6, monitor:HDMI-A-3"
        "7, monitor:HDMI-A-3"

        "2, monitor:DP-1"
      ];

      windowrulev2 = [
        "workspace 1,class:^(kitty)$"
        "workspace 2,title:^(Spotify Premium)$"
        "workspace 3,class:^(firefox)$"
        "workspace 4,class:^(org.telegram.desktop)$"

        "workspace 5,class:^(com.usebottles.bottles)$"
        "workspace 5,class:^(battle.net.exe)$"
        "workspace 5,class:^(wow.exe)$"
        "workspace 5,class:^(steam)$"

        "workspace 6,class:^(org.keepassxc.KeePassXC)$"
        "workspace 7,class:^(WowUpCf)$"
      ];

      exec-once = [
        "kitty"
        "firefox"
        "telegram-desktop"
        "keepassxc"
        "spotify"
        "steam"
        "xrandr --output HDMI-A-3 --primary"
      ];

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "XCURSOR_SIZE,24"
        "GBM_BACKEND,nvidia-drm"
        "__VK_LAYER_NV_optimus,NVIDIA_only"
        "NVD_BACKEND,direct"
        "WLR_DRM_NO_ATOMIC,1"
      ];

      render = { explicit_sync = 0; };

    };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#towerSys switch";
    homeswitch = "home-manager switch --flake .#towerHome";
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
