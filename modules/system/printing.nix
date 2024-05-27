{ pkgs, ... }: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cnijfilter2 ];
  };
  # Enable Printer autodiscovery.
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };
  # Enable scanning.
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };
}
