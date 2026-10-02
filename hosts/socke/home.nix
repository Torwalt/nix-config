{ pkgs, ... }:

{
  home = {
    username = "socke";
    homeDirectory = "/home/socke";
    stateVersion = "26.05";

    packages = with pkgs; [
      # Agents to ask when something about the system is unclear.
      antigravity
      gemini-cli

      firefox
      libreoffice
      vlc
      spotify
      vesktop
      telegram-desktop
    ];
  };

  # A launcher, so reaching the agent does not start with finding a terminal.
  xdg.desktopEntries.gemini = {
    name = "Ask Gemini";
    exec = "${pkgs.kdePackages.konsole}/bin/konsole -e ${pkgs.gemini-cli}/bin/gemini";
    icon = "utilities-terminal";
    terminal = false;
    categories = [ "Utility" ];
  };
}
