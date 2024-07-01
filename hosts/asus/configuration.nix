{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/greetd/default.nix
    ../../modules/system/fonts.nix
  ];

  system.stateVersion = "25.05";
  boot.initrd.luks.devices."luks-602060e4-224b-46e2-9685-e8d6fed418d6".device =
    "/dev/disk/by-uuid/602060e4-224b-46e2-9685-e8d6fed418d6";

  powerManagement.cpuFreqGovernor = "performance";

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
    timeout = 30;
  };
}
