{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
  ];

  boot.initrd.luks.devices."luks-7467625b-5d73-418d-9dcc-ade392ca09c9".device =
    "/dev/disk/by-uuid/7467625b-5d73-418d-9dcc-ade392ca09c9";

  system.stateVersion = "24.05";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
    timeout = 30;
  };

  # Enable OpenGL
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };

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

  environment.systemPackages = with pkgs; [ distrobox dpkg osquery ];
}
