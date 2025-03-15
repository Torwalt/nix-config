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
      Unit = { Description = "Stop Timewarrior work"; };

      Service = {
        Type = "oneshot";
        ExecStop = "${pkgs.timewarrior}/bin/timew stop work";
        StandardOutput = "journal";
        RemainAfterExit = "yes";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  home.packages = with pkgs; [ timewarrior ];
}
