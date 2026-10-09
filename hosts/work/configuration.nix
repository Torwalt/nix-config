{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/workstation.nix
    ../../modules/system/codex.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/greetd/default.nix
    ../../modules/system/fonts.nix
    ../../modules/system/audio.nix
    ../../modules/system/tuxedo.nix
    ../../modules/system/monitor-follow.nix
  ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  system.stateVersion = "25.11";

  monitorFollow.input = "0x12";

  audio.preferredInput = "~alsa_input\\.usb-GeneralPlus_USB_Audio_Device-.*";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
    timeout = 30;
  };

  services.power-profiles-daemon.enable = true;

  zramSwap.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.rocm-runtime
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  hardware.graphics.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];

  nix.settings.trusted-users = [
    "root"
    "ada"
  ];

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
