{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      gcc
      jq
      python3
      gnumake
      nixfmt-classic
      ffmpeg
      htop
      btop
      file
      ruplacer
      tree
      unzip
      cloc
      dig
      nap

      # GUI
      keepassxc
      # firefox
      pavucontrol
      spotify
      chromium
      maestral-gui
      gwenview

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

    sessionVariables = { LESS = "-CR"; };
  };

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };
}
