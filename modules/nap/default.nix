{
  home = {
    file.nap = {
      enable = true;
      source = ./config.yaml;
      target = "/home/ada/.config/nap/config.yaml";
    };

    sessionVariables = {
      NAP_CONFIG = "/home/ada/.config/nap/config.yaml";
      XDG_CONFIG_HOME = "/home/ada/.config";
      # This should not be required, but better have it to make sure.
      NAP_HOME = "/home/ada/repos/notes/snippets";
    };
  };
}
