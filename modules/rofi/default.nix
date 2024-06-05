{ lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    font = lib.mkForce "DejaVu Sans Mono 15";
    package = pkgs.rofi-wayland;
  };
}
