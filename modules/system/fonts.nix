{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    noto-fonts
    noto-fonts-color-emoji
    proggyfonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];

  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      noto-fonts-color-emoji
      proggyfonts
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
    ];
  };

}
