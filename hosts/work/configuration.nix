{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/greetd/default.nix
    ../../modules/system/virtualisation/libvirtd/default.nix
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

  boot.initrd.luks.devices."luks-25805164-d8bc-45c4-9918-09ffd240bc1e".device =
    "/dev/disk/by-uuid/25805164-d8bc-45c4-9918-09ffd240bc1e";

  # vpn
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  networking.firewall = {
    enable = true;

    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];
  };
}
