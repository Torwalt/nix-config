{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
    # ../../modules/vanta/module.nix
  ];

  boot.initrd.luks.devices."luks-7467625b-5d73-418d-9dcc-ade392ca09c9".device =
    "/dev/disk/by-uuid/7467625b-5d73-418d-9dcc-ade392ca09c9";

  system.stateVersion = "24.11";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
    timeout = 30;
  };

  powerManagement.cpuFreqGovernor = "performance";

  # services.resolved.enable = true;

  # services.openvpn.servers = {
  #   officeVPN = {
  #     config = "config /home/ada/client.ovpn.bkp";
  #     updateResolvConf = true;
  #     autoStart = false;
  #   };
  # };
  # networking.networkmanager.dns = "systemd-resolved";

  # This is required in order to pull some moby images as they have high uid/guid set.
  # See https://github.com/moby/moby/issues/43576#issuecomment-1136056638.
  users.users.ada = {
    subUidRanges = [
      {
        count = 65536;
        startUid = 100000;
      }
      {
        count = 1000000;
        startUid = 1000000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = 100000;
      }
      {
        count = 1000000;
        startGid = 1000000;
      }
    ];
  };

  # Increase ulimit for procs because of a docker image setting for work.
  security.pam.loginLimits = [{
    domain = "*";
    type = "-";
    item = "nproc";
    value = "65536";
  }];

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  nixpkgs.config.allowUnfree = true;

  # Required for vanta-agent.
  services.osquery = {
    enable = false;
    flags = {
      extensions_autoload = ''
        /var/vanta/osquery-vanta.ext
      '';
    };

    settings = {
      options = {
        logger_path = "/var/log/osquery";
        disable_logging = false;
        schedule_splay_percent = 10;
      };

      schedule = {
        system_info = {
          query =
            "SELECT hostname, cpu_brand, physical_memory FROM system_info;";
          interval = 3600;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    distrobox
    dpkg
    osquery
    lm_sensors
    dmidecode
    libsmbios
  ];
}
