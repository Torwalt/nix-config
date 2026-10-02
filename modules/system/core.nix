{ lib, pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  networking = {
    hostName = lib.mkDefault "nixos";

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
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    xkb = {
      variant = "";
      layout = "de";
    };

  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    always-allow-substitutes = true;
    builders-use-substitutes = true;
  };

  # Generation retention is handled by `nixup clean`. This weekly pass only
  # removes paths that are already unreferenced, including temporary builds.
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Deduplicate identical files in the store without doing the work on every
  # package installation.
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
