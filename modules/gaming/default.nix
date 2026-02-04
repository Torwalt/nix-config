{ pkgs, ... }: {
  home = { packages = with pkgs; [ wowup-cf nexusmods-app protontricks ]; };
}
