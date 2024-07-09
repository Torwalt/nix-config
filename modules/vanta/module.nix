{ ... }: {
  systemd.services.vanta = {
    after = [ "network.service" "syslog.service" "osqueryd.service" ];
    description = "Vanta monitoring software";
    wantedBy = [ "multi-user.target" ];
    script = ''
      /var/vanta/launcher
    '';

    serviceConfig = {
      TimeoutStartSec = 0;
      Restart = "on-failure";
      KillMode = "control-group";
      KillSignal = "SIGTERM";
    };
  };
}
