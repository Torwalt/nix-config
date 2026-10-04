{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.monitorFollow;
in
{
  options.monitorFollow = {
    input = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "0x11";
      description = ''
        DDC/CI input source code (VCP 0x60) of this host's cable on the shared
        monitor. When set, the monitor is switched to it whenever the shared
        USB hub is switched to this host.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "ASUS MG279";
      description = "EDID model name of the shared monitor.";
    };

    usbDevice = lib.mkOption {
      type = lib.types.str;
      default = "1b1c:1b40";
      description = ''
        vendor:product of a device behind the shared hub; its arrival means the
        hub was switched to this host.
      '';
    };
  };

  config = lib.mkIf (cfg.input != null) (
    let
      ids = lib.splitString ":" cfg.usbDevice;
    in
    {
      hardware.i2c.enable = true;
      users.users.ada.extraGroups = [ "i2c" ];
      environment.systemPackages = [ pkgs.ddcutil ];

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="${builtins.elemAt ids 0}", ATTR{idProduct}=="${builtins.elemAt ids 1}", RUN+="${pkgs.systemd}/bin/systemctl start --no-block monitor-follow.service"
      '';

      systemd.services.monitor-follow = {
        description = "Switch the shared monitor to this host";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.ddcutil}/bin/ddcutil --model '${cfg.model}' setvcp 60 ${cfg.input}";
        };
      };
    }
  );
}
