{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      gcc
      jq

      (python312.withPackages (ps: with ps; [ ipython virtualenv ]))

      gnumake
      nixfmt
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
      files-to-prompt

      # GUI
      keepassxc
      # firefox
      pavucontrol
      spotify
      maestral-gui

      # Screenshots
      grim
      slurp
      wl-clipboard
      swappy

      # encryption
      sops
      age
      ssh-to-age
    ];

    sessionVariables = { LESS = "-CR"; };
  };

  programs.home-manager.enable = true;

  fonts = { fontconfig.enable = true; };

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,UsePortalFilePicker"
    ];
  };

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = true;
    };
  };
}
