{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/stylix/default.nix
    ../../modules/system/default.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/greetd/default.nix
    ../../modules/system/fonts.nix
  ];

  system.stateVersion = "25.05";

  powerManagement.cpuFreqGovernor = "performance";

  nixpkgs.config.allowUnfree = true;
}
