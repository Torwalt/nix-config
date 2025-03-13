{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    lazydocker
  ];

  home.file.".config/lazydocker/config.yml".source = ./config.yml;
}
