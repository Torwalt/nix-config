{ ... }: {

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
