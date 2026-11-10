{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.monitorFollow;

  switchMonitor = pkgs.writeShellApplication {
    name = "monitor-follow";
    runtimeInputs = with pkgs; [
      coreutils
      ddcutil
      gawk
      gnugrep
    ];
    text = ''
      model=${lib.escapeShellArg cfg.model}
      input=${lib.escapeShellArg cfg.input}
      cache=/run/monitor-follow/bus

      # Addressing the bus directly skips ddcutil's probe of every bus.
      set_input() {
        ddcutil --bus "$1" --skip-ddc-checks --noverify setvcp 60 "$input"
      }

      # Drivers that link a connector to its DDC adapter (amdgpu, i915) give
      # the bus of the connector whose EDID names the monitor.
      for c in /sys/class/drm/card*-*; do
        if [[ -e $c/ddc ]] && grep -qaF -- "$model" "$c/edid" 2>/dev/null; then
          bus=$(readlink -f "$c/ddc")
          set_input "''${bus##*/i2c-}" && exit 0
        fi
      done

      # Others (nvidia) reuse the bus that an earlier detection found.
      if [[ -s $cache ]] && set_input "$(<"$cache")"; then
        exit 0
      fi

      bus=$(ddcutil detect --terse 2>/dev/null | awk -v model="$model" '
        /I2C bus:/ { sub(/.*\/dev\/i2c-/, ""); bus = $0 }
        /Monitor:/ && index($0, ":" model ":") { print bus; exit }
      ') || true
      if [[ -z $bus ]]; then
        echo "no DDC/CI display named $model found" >&2
        exit 1
      fi
      echo "$bus" >"$cache"
      set_input "$bus"
    '';
  };

  hubMatch = lib.concatStringsSep ", " (
    lib.mapAttrsToList (attr: value: ''ATTR{${attr}}=="${value}"'') cfg.usbHub
  );
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
        USB switch is switched to this host.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "ASUS MG279";
      description = "EDID model name of the shared monitor.";
    };

    usbHub = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        idVendor = "05e3";
        idProduct = "0610";
        bcdDevice = "0663";
      };
      description = ''
        sysfs attributes of the USB switch's own hub. The hub enumerates before
        the peripherals behind it, so its arrival is the earliest sign that the
        switch was switched to this host. bcdDevice tells it apart from other
        hubs built on the same Genesys Logic chip.
      '';
    };
  };

  config = lib.mkIf (cfg.input != null) {
    hardware.i2c.enable = true;
    users.users.ada.extraGroups = [ "i2c" ];
    environment.systemPackages = [ pkgs.ddcutil ];

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ${hubMatch}, RUN+="${pkgs.systemd}/bin/systemctl start --no-block monitor-follow.service"
    '';

    systemd.services.monitor-follow = {
      description = "Switch the shared monitor to this host";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe switchMonitor;
        RuntimeDirectory = "monitor-follow";
        RuntimeDirectoryPreserve = true;
      };
    };
  };
}
