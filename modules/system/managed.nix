{ config, lib, ... }:

let
  cfg = config.managedHost;
in
{
  imports = [ ./core.nix ];

  options.managedHost = {
    enable = lib.mkEnableOption "the profile for a host its user does not administer";

    flake = lib.mkOption {
      type = lib.types.str;
      example = "github:Torwalt/nix-config/socke-stable#sockeSys";
      description = ''
        Flake reference this host upgrades itself from. The upgrade runs
        unattended as root, so the reference must resolve without credentials.
      '';
    };

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Login name of the day-to-day account.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Name shown on the login screen.";
      };
    };

    admin.name = lib.mkOption {
      type = lib.types.str;
      default = "ada";
      description = "Login name of the second account, which keeps sudo.";
    };
  };

  config = lib.mkIf cfg.enable {
    # The day-to-day account has no sudo. This host changes by upgrading the
    # flake, not by editing the running system.
    users.users.${cfg.user.name} = {
      isNormalUser = true;
      description = cfg.user.description;
      extraGroups = [ "networkmanager" ];
    };

    users.users.${cfg.admin.name} = {
      isNormalUser = true;
      description = "administrator";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    # `boot` rather than `switch`: a new generation becomes the default without
    # restarting services underneath a running session.
    system.autoUpgrade = {
      enable = true;
      flake = cfg.flake;
      operation = "boot";
      dates = "daily";
      randomizedDelaySec = "45min";
      persistent = true;
      allowReboot = false;
    };

    # Nothing prunes generations here the way `nixup clean` does elsewhere, and
    # a daily upgrade would otherwise grow the store without bound.
    nix.gc.options = lib.mkDefault "--delete-older-than 30d";
  };
}
