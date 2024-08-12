{
  home = {
    file.nap = {
      enable = true;
      source = ./config.yaml;
      target = "/home/ada/.config/nap/config.yaml";
    };

    sessionVariables = { NAP_CONFIG = "home/ada/.config/nap/config.yaml"; };
  };

}
