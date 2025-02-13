{ pkgs, ... }: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = false;
    drivers = with pkgs; [ cnijfilter2 ];

    # Due to CUPS CVE
    browsed.enable = false;
    browsing = false;
    startWhenNeeded = false;
  };
  # Enable Printer autodiscovery.
  services.avahi = {
    enable = false;
    nssmdns4 = false;
    openFirewall = false;
  };
  # Enable scanning.
  hardware.sane = {
    enable = false;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };
}
