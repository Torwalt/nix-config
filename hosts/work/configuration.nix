{ lib, ... }: {
  imports = [
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
  ];

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
}
