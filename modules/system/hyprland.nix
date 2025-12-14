{ pkgs, ... }: {

  # wayland and hyperland related stuff
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = { XDG_SESSION_TYPE = "wayland"; };

  environment.systemPackages = with pkgs; [
    # notifier
    dunst
    # dependency for all notifiers
    libnotify
    # wallpapers
    swww
  ];
}
