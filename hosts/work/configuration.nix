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

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ distrobox dpkg osquery ];
}
