{ pkgs, inputs, ... }:

let
  homeDirectory = "/home/ada";
in {
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/default.nix
    ../../modules/stylix/home.nix
    ../../modules/rofi/default.nix
    ../../modules/nap/default.nix
    ../../modules/python/default.nix
    ../../modules/direnv/default.nix
    ../../modules/delve/default.nix
    ../../modules/go/default.nix

    ../../modules/nvim/nvim.nix

    ../../modules/cli/all.nix

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
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # Monitor config
      nwg-displays
      wlr-randr

      libreoffice
      go-task
      pdm
      nodejs_18
      pnpm
      binaryen
      temporal-cli
      tailscale
      beekeeper-studio
      postgresql
      _1password-cli
      azure-cli
      pulumi-bin
    ];

    sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#workSys switch";
    homeswitch = "home-manager switch --flake .#workHome";
    # buildFHSUserEnv ignores --command, but you can still start zsh afterwards.
    nodejsshell = "nix develop ~/nix-config#nodejs";
    azureclishell = "nix develop ~/nix-config#azurecli";
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "eDP-1,2560x1600@240.00000,0x0,1.0"
        "HDMI-A-1,2560x1440@99.95,2560x0,1.0"
      ];

      workspace = [
        "1, monitor:HDMI-A-1"
        "3, monitor:HDMI-A-1"
        "4, monitor:HDMI-A-1"
        "5, monitor:HDMI-A-1"
        "6, monitor:HDMI-A-1"
        "7, monitor:HDMI-A-1"

        "2, monitor:eDP-1"
      ];

      windowrulev2 = [
        "workspace 1,class:^(kitty)$"
        "workspace 2,title:^(Spotify Premium)$"
        "workspace 3,class:^(firefox)$"
        "workspace 4,class:^(chromium-browser)$"
        "workspace 5,class:^(beekeeper-studio)$"

        "workspace 6,class:^(org.keepassxc.KeePassXC)$"
      ];

      exec-once = [
        "kitty"
        "firefox"
        "keepassxc"
        "spotify"
        "chromium-browser"
        "beekeeper-studio"
      ];

    };
  };
}
