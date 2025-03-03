{ pkgs, ... }: {

  home = {
    packages = with pkgs; [ go delve ];
    sessionPath = [ "$HOME/go/bin" ];
  };

  programs.go = {
    enable = true;
    goBin = "go/bin";
    goPath = "go";
  };
}
