{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      gcc
      jq

      python3
      python312Packages.ipython

      gnumake
      nixfmt-classic
      ffmpeg
      btop
      file
      ruplacer
      tree
      unzip
      # cloc replacement - written in rust btw
      tokei
      dig
      nap
      lldb

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
  home.stateVersion = "24.11";

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };
}
