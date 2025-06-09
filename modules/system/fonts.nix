{ lib, pkgs, ... }:

let fastFontOverlay = import ../../modules/fastfonts/overlay.nix;
in {
  nixpkgs.overlays = [ fastFontOverlay ];

  environment.systemPackages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    noto-fonts
    noto-fonts-emoji
    proggyfonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    fast-font
  ];

  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      noto-fonts-emoji
      proggyfonts
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      fast-font
    ];
  };

}
