{ pkgs, ... }: {

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";

    extraConfig = {
      url = {
        "ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
      };
    };

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        paging = "always";
      };
    };

    ignores = [ ".git" ];

    extraConfig = {
      delta = { navigate = true; };
      merge = { conflictstyle = "diff3"; };
      diff = { colorMoved = "default"; };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home = {
    packages = with pkgs; [ go delve ];
    sessionPath = [ "$HOME/go/bin" ];
  };

  programs.go = {
    enable = true;
    goBin = "go/bin";
    goPath = "go";
  };

  programs.kitty = { enable = true; };

  services.dunst = {
    enable = true;
    settings.global.monitor = 1;
  };

  programs.btop = { enable = true; };
}
