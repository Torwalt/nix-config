{ config, lib, pkgs, ... }:

{
  systemd.user.services = {
    # Services to start timew and stop on shutdown.
    timewarrior-start-work = {
      Unit = { Description = "Start Timewarrior work"; };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.timewarrior}/bin/timew start work";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };

    timewarrior-stop-work = {
      Unit = {
        Description = "Stop Timewarrior work";
        Before = [ "shutdown.target" "reboot.target" "halt.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.timewarrior}/bin/timew stop work";
        TimeoutStartSec = "10s";
      };

      Install = {
        WantedBy = [ "shutdown.target" "reboot.target" "halt.target" ];
      };
    };
  };

  home.packages = with pkgs; [ timewarrior ];
}
