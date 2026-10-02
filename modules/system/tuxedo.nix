{ pkgs, ... }:
{
  # tailord owns fan curves and keyboard backlight, tailor-gui replaces the
  # TUXEDO Control Center. Pulls in hardware.tuxedo-drivers.
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # Ryzen mobile power limits: STAPM, PPT, TDC, EDC. Root only.
  environment.systemPackages = [ pkgs.ryzenadj ];
}
