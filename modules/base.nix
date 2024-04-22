{ pkgs, ... }: {
  home.packages = with pkgs; [
    gcc
    jq
    keepassxc
    python3
    gnumake
    nixfmt
    firefox
    pavucontrol
    ffmpeg
    spotify
    chromium
    htop
    btop

    # Screenshots
    grim
    slurp
    wl-clipboard
    swappy

    # Fonts
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    proggyfonts
  ];

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
