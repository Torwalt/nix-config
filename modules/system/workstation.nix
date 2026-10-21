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
      daemon.settings.cgroup-parent = "containers.slice";
    };
  };

  # Stricter than -.slice, so oomd kills a dev container first.
  systemd.user.slices.containers.sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "30%";
    ManagedOOMMemoryPressureDurationSec = "10s";
  };

  # Kills the cgroup with the most swap once RAM and swap both pass 90 %.
  # Kills the cgroup with the most reclaim after 20 s at 60 % memory stall.
  systemd.oomd.enableRootSlice = true;
  systemd.slices."-".sliceConfig = {
    ManagedOOMSwap = "kill";
    ManagedOOMMemoryPressureLimit = "60%";
    ManagedOOMMemoryPressureDurationSec = "20s";
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
