{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      gcc
      jq

      (python312.withPackages (ps: with ps; [ ipython virtualenv ]))

      gnumake
      nixfmt-classic
      ffmpeg
      btop
      file
      ruplacer
      tree
      zip
      unzip
      # cloc replacement - written in rust btw
      tokei
      dig
      nap
      lldb
      tldr
      wget

      # GUI
      keepassxc
      # firefox
      pavucontrol
      spotify
      chromium
      maestral-gui

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
      noto-fonts
      noto-fonts-emoji
      proggyfonts
      nerd-fonts.fira-code
    ];

    sessionVariables = { LESS = "-CR"; };
  };

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = true;
    };
  };
}
