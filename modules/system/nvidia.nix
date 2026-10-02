{ ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Wayland and for the DRM console handover.
    modesetting.enable = true;

    # Saving VRAM across suspend costs time and can itself break sleep.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # The open kernel module needs Turing or newer. The proprietary one is
    # the proven path on these cards.
    open = false;

    nvidiaSettings = true;
  };
}
