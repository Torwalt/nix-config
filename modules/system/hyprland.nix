{ pkgs, inputs, ... }:
let tokyo-night-sddm = pkgs.libsForQt5.callPackage ./tokyo-night-sddm.nix { };
in {
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

    # app launcher
    rofi-wayland

    tokyo-night-sddm
  ];

  # Wayland needed for hyprland.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "tokyo-night-sddm";
    };
  };
}
