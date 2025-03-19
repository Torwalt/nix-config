{ pkgs, ... }:

{
  stylix = {
    enable = true;
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    image = ../../wp.png;
    polarity = "dark";
  };
}
