{ pkgs, ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
      };
    };
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.mesa ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

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
              # m17n transliteration rules expect US Latin key positions.
              Layout = "us";
            };
          };
        };
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    xkb = {
      options = "caps:escape";
      variant = "";
      layout = "de";
    };

  };

  # Configure console keymap
  console.keyMap = "de";

  environment.sessionVariables = {
    # Prefer native Wayland input, with the Fcitx plugin as a Qt fallback.
    QT_IM_MODULES = "wayland;fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  users.users.ada = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  system.stateVersion = "25.11";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    always-allow-substitutes = true;
    builders-use-substitutes = true;
  };
}
