{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
  ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

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

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
    rocmPackages.clr
    rocmPackages.rocm-runtime
    vaapiVdpau
    libvdpau-va-gl
  ];

  hardware.graphics.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
}
