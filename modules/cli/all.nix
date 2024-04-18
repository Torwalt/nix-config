{ ... }: {

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";

    delta.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    goBin = "go/bin";
    goPath = "go";
  };
}
