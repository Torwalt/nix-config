{ ... }: {
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 49.0;
    longitude = 8.4;
  };
}
