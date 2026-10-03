{ pkgs, ... }:
{
  imports = [ ./core.nix ];

  services.xserver.xkb.options = "caps:escape";

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        addons = [ pkgs.fcitx5-m17n ];
        waylandFrontend = true;

        # ru-translit does not use a writable dictionary, so ignoring user
        # configuration keeps this two-mode profile reproducible.
        ignoreUserConfig = true;
        settings = {
          globalOptions.Hotkey.TriggerKeys = "";

          inputMethod = {
            "GroupOrder"."0" = "German and Russian translit";
            "Groups/0" = {
              Name = "German and Russian translit";
              "Default Layout" = "de";
              DefaultIM = "m17n_ru_translit";
            };
            "Groups/0/Items/0" = {
              Name = "keyboard-de";
              Layout = "de";
            };
            "Groups/0/Items/1" = {
              Name = "m17n_ru_translit";
              # Feed the transliterator from the German QWERTZ layout.
              Layout = "de";
            };
          };
        };
      };
    };
  };

  environment.sessionVariables = {
    # Prefer native Wayland input, with the Fcitx plugin as a Qt fallback.
    QT_IM_MODULES = "wayland;fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  services.blueman.enable = true;

  users.users.ada = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [
      "gamemode"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    # Is true by default. If this also enabled on home-manager,
    # then this slows down zsh startup significantly.
    enableCompletion = false;
  };

  # docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Make sure docker is killed first if some container has a memory leak.
  systemd.services.docker = {
    # The higher the value (max 1000) the higher prio for killing.
    serviceConfig.OOMScoreAdjust = 999;
  };

  environment.systemPackages = with pkgs; [
    home-manager

    networkmanagerapplet

    # terminal
    kitty

    os-prober
    gparted
    at
  ];

  services.atd.enable = true;
}
