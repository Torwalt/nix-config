{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/workstation.nix
    ../../modules/system/codex.nix
    ../../modules/system/printing.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/gaming.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/greetd/default.nix
    ../../modules/system/fonts.nix
    ../../modules/system/audio.nix
    ../../modules/system/monitor-follow.nix
    # ../../modules/system/ai/default.nix
  ];

  system.stateVersion = "25.11";

  monitorFollow.input = "0x11";

  audio.preferredInput = "~alsa_input\\.usb-(?!.*([Cc]amera|[Ww]ebcam)).*";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
    timeout = 30;
  };

  hardware = {
    graphics = {
      enable32Bit = true;
    };

    nvidia = {
      forceFullCompositionPipeline = true;
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = 1;
    CLUTTER_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
