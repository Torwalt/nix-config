{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [ mangohud protonup bottles wine winetricks protonup-qt ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/user/.steam/root/compatibilitytools.d";
  };

  programs.gamemode.enable = true;
}
