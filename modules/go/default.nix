{ pkgs, ... }: {

  home = {
    packages = with pkgs; [ go delve ];
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = { PATH = "$HOME/go/bin:$PATH"; };
  };

  programs.go = {
    enable = true;
    goBin = "go/bin";
    goPath = "go";
  };
}
