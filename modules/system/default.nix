{ pkgs, ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;
      wifi = { powersave = false; };
    };
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.mesa.drivers ];
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
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    xkb = {
      options = "caps:swapescape";
      variant = "";
      layout = "de";
    };

  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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
    extraGroups = [ "networkmanager" "wheel" ];
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

  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
