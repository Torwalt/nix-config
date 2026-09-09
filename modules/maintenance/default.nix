{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixup;
  system = pkgs.stdenv.hostPlatform.system;
  homeManager = inputs.home-manager.packages.${system}.home-manager;

  nixup = pkgs.writeShellApplication {
    name = "nixup";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      git
      gnused
      nix
      nixos-rebuild
      util-linux
      homeManager
    ];
    text = ''
      export NIXUP_SYSTEM_CONFIGURATION=${lib.escapeShellArg cfg.systemConfiguration}
      export NIXUP_HOME_CONFIGURATION=${lib.escapeShellArg cfg.homeConfiguration}
      export NIXUP_DEFAULT_REPO=${lib.escapeShellArg cfg.repository}
      export NIXUP_RETAIN_GENERATIONS=${toString cfg.retainGenerations}
      export NIXUP_REMINDER_DAYS=${toString cfg.reminderDays}

      ${builtins.readFile ./nixup.sh}
    '';
  };
in
{
  options.programs.nixup = {
    enable = lib.mkEnableOption "the NixOS and Home Manager maintenance workflow";

    systemConfiguration = lib.mkOption {
      type = lib.types.str;
      description = "Name of this host's nixosConfigurations flake output.";
    };

    homeConfiguration = lib.mkOption {
      type = lib.types.str;
      description = "Name of this host's homeConfigurations flake output.";
    };

    repository = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix-config";
      description = "Default path to the system configuration flake.";
    };

    retainGenerations = lib.mkOption {
      type = lib.types.ints.positive;
      default = 4;
      description = "Number of NixOS and Home Manager generations to retain.";
    };

    reminderDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 14;
      description = "Days after a successful deployment before showing a reminder.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ nixup ];

    programs.zsh.shellAliases = {
      sysswitch = "sudo nixos-rebuild switch --flake ${lib.escapeShellArg "${cfg.repository}#${cfg.systemConfiguration}"}";
      homeswitch = "home-manager switch --flake ${lib.escapeShellArg "${cfg.repository}#${cfg.homeConfiguration}"}";
    };

    # `remind` rate-limits itself to one message per day.
    programs.zsh.initContent = lib.mkAfter ''
      nixup remind
    '';
  };
}
