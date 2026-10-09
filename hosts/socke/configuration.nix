{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/managed.nix
    ../../modules/system/plasma.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/gaming.nix
    ../../modules/system/fonts.nix
  ];

  system.stateVersion = "26.05";

  networking.hostName = "socke";

  zramSwap.enable = true;

  managedHost = {
    enable = true;
    flake = "github:Torwalt/nix-config/socke-stable#sockeSys";
    user = {
      name = "socke";
      description = "socke";
    };
  };

  # Windows keeps the real time clock on local time. Without this the Windows
  # clock jumps by the UTC offset after every boot into NixOS.
  time.hardwareClockInLocalTime = true;

  # Enough to read the Windows partition. Steam libraries must not live there:
  # Proton needs a case-sensitive filesystem with real permissions.
  boot.supportedFilesystems.ntfs = true;

  # UEFI dual boot. For a legacy/CSM install instead: efiSupport = false and
  # grub.device set to the disk, for example "/dev/sda".
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    # The Windows ESP is typically 100 MB, far too small for NixOS kernels.
    # GRUB reads ext4, so only its EFI stub goes there and /boot stays on root.
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
    };
    # Rolling back is picking an older entry here, so leave time to read it.
    timeout = 10;
  };

  hardware.graphics.enable32Bit = true;

  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;

  programs.steam = {
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    os-prober
    heroic
    lutris
    protonplus
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Driverless network printers.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.fwupd.enable = true;
}
