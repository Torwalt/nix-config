{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixup;
  diskgcCfg = config.programs.diskgc;
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

  diskgc = pkgs.writeShellApplication {
    name = "diskgc";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gawk
      gh
      git
      gnugrep
      gnused
      jq
    ];
    text = ''
      export DISKGC_REPO_ROOTS=${lib.escapeShellArg (lib.concatStringsSep ":" diskgcCfg.repositoryRoots)}
      export DISKGC_EXPIRING_DIRS=${lib.escapeShellArg (lib.concatStringsSep ":" diskgcCfg.expiringDirectories)}
      export DISKGC_MAX_AGE_DAYS=${toString diskgcCfg.maxAgeDays}
      export DISKGC_LARGE_DIR_GIB=${toString diskgcCfg.largeDirectoryGiB}
      export NIXUP_RETAIN_GENERATIONS=${toString cfg.retainGenerations}

      ${builtins.readFile ./diskgc.sh}
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

  options.programs.diskgc = {
    enable = lib.mkEnableOption "the disk garbage report and cleanup command";

    repositoryRoots = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.home.homeDirectory}/repos" ];
      description = "Directories whose Git checkouts have their linked worktrees checked.";
    };

    expiringDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/tmp"
        "/var/tmp"
        "/var/tmp/*"
        "/tmp/claude-*/*"
      ];
      description = "Directories, as shell globs, whose untouched entries are deleted.";
    };

    maxAgeDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 7;
      description = "Days without a modification before an expiring entry is deleted.";
    };

    largeDirectoryGiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Size from which directories in ~/.cache and ~/.local/share are reported.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf diskgcCfg.enable {
      assertions = [
        {
          assertion = cfg.enable;
          message = "programs.diskgc cleans Nix through nixup; enable programs.nixup too.";
        }
      ];
      home.packages = [ diskgc ];
    })
    (lib.mkIf cfg.enable {
      home.packages = [ nixup ];

      programs.zsh.shellAliases = {
        sysswitch = "sudo nixos-rebuild switch --flake ${lib.escapeShellArg "${cfg.repository}#${cfg.systemConfiguration}"}";
        homeswitch = "home-manager switch --flake ${lib.escapeShellArg "${cfg.repository}#${cfg.homeConfiguration}"}";
      };

      # `remind` rate-limits itself to one message per day.
      programs.zsh.initContent = lib.mkAfter ''
        nixup remind
      '';
    })
  ];
}
