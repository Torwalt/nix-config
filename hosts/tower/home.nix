{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      mpvpaper = prev.mpvpaper.overrideAttrs (oldAttrs: {
        src = prev.fetchFromGitHub {
          owner = "GhostNaN";
          repo = "mpvpaper";
          rev = "d8164bb6bd2960d2f7f6a9573e086d07d440f037";
          hash = "sha256-/A2C6T7gP+VGON3Peaz2Y4rNC63UT+zYr4RNM2gdLUY=";
        };
      });
    })
  ];

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

      mpvpaper
      libreoffice
      gimp-with-plugins

      # Non programming
      telegram-desktop
      discord
      libresprite
      renderdoc
    ];

    # sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "DP-1,2560x1440@59.95,0x0,1.0"
        "HDMI-A-3,2560x1440@99.95,2560x0,1.0"
      ];

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

    };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#towerSys switch";
    homeswitch = "home-manager switch --flake .#towerHome";
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
