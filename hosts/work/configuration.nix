{ lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
  ];

  system.stateVersion = "24.11";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      timeout = 30;
      default = 0;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    timeout = 30;
  };

  powerManagement.cpuFreqGovernor = "performance";

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  nixpkgs.config.allowUnfree = true;
}
