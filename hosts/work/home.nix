{ pkgs, inputs, lib, ... }:

let homeDirectory = "/home/ada";
in {
  imports = [
    ../../modules/base.nix
    ../../modules/stylix/home.nix
    ../../modules/rofi/default.nix
    ../../modules/nap/default.nix

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
      openvpn

      libreoffice
      slack
      (google-cloud-sdk.withExtraComponents
        [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      beekeeper-studio
      go-task
      postgresql
      golangci-lint
      clickhouse

      kubectl
      kubectx
    ];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = 1;
      TALONSERVICEPATH = "${homeDirectory}/repos/talon-service";
      TALON_CH_ENABLED = "true";
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "eDP-1,1920x1200@59.95000,0x0,1.0"
        "DP-3,2560x1440@59.95Hz,2560x0,1.0"
      ];

      workspace = [
        "1, monitor:DP-3"
        "3, monitor:DP-3"
        "4, monitor:DP-3"
        "5, monitor:DP-3"
        "6, monitor:DP-3"
        "7, monitor:DP-3"

        "2, monitor:eDP-1"
      ];

      windowrulev2 = [
        "workspace 1,class:^(kitty)$"
        "workspace 2,title:^(Spotify Premium)$"
        "workspace 3,class:^(firefox)$"
        "workspace 4,class:^(Slack)$"
        "workspace 5,class:^(beekeeper-studio)$"
        "workspace 6,class:^(org.keepassxc.KeePassXC)$"
      ];

      exec-once = [
        "kitty"
        "firefox"
        "slack"
        "beekeeper-studio --use-gl=desktop"
        "keepassxc"
        "spotify"
        "xrandr --output DP-1 --primary"
      ];
    };

  };

  programs.zsh.shellAliases = {
    sysswitch = "sudo nixos-rebuild --flake .#workSys switch";
    homeswitch = "home-manager switch --flake .#workHome";
  };

  programs.git = { userEmail = lib.mkForce "dadiani@talon.one"; };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-city-dark;
}
