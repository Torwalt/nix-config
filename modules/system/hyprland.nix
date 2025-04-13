{ pkgs, inputs, ... }:
let tokyo-night-sddm = pkgs.libsForQt5.callPackage ./tokyo-night-sddm.nix { };
in {

  nixpkgs.overlays = [
    (final: prev: {
      sddm = prev.sddm.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          ln -sf $out/bin/sddm-greeter $out/bin/sddm-greeter-qt6
        '';
      });
    })
  ];

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
    sddm-astronaut
  ];

  # Wayland needed for hyprland.
  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      package = pkgs.kdePackages.sddm; # qt6 sddm version
      extraPackages = [ pkgs.sddm-astronaut ];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
    };
  };
}
