{ pkgs, config, ... }: {

  home = { packages = with pkgs; [ go delve gotestsum]; };

  programs.go = {
    enable = true;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };
  };
}
