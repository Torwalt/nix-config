{ pkgs, ... }:

{
  stylix = {
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    image = ./wp.jpg;
    polarity = "dark";
  };
}
