{ pkgs, ... }:
{
  services.displayManager = {
    sddm = {
      enable = true;
      # The greeter stays on X11. On NVIDIA that is the path with fewer
      # surprises before a session exists.
      wayland.enable = false;
    };

    # Wayland by default. The `plasmax11` session stays installed and is
    # selectable from the session menu on the login screen.
    defaultSession = "plasma";
  };

  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];
}
