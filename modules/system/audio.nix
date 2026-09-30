{ config, lib, ... }:

let
  cfg = config.audio;
in
{
  options.audio.preferredInput = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "~alsa_input\\.usb-GeneralPlus_USB_Audio_Device-.*";
    description = ''
      WirePlumber node.name match for the input that should win default
      source selection. A leading `~` makes it a regex.
    '';
  };

  config = lib.mkIf (cfg.preferredInput != null) {
    # Beats the ALSA auto-priorities (~2000-2100), which otherwise favour webcams.
    # An explicit choice in pavucontrol/wpctl still overrides it.
    services.pipewire.wireplumber.extraConfig."51-preferred-input" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = cfg.preferredInput; } ];
          actions.update-props = {
            "priority.session" = 3000;
            "priority.driver" = 3000;
          };
        }
      ];
    };
  };
}
