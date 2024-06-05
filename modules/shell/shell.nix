{ pkgs, ... }: {
  # In order for .profile being updated.
  programs.bash = { enable = true; };

  home.packages = with pkgs; [
    zsh-vi-mode
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    autocd = true;

    shellAliases = {
      gs = "git status";
      gg = "git checkout";
      ga = "git add .";
      gc = "git commit";
      gam = "git commit --amend";
      gfp = "git push --force-with-lease";
      v = "nvim";
      rustshell = "nix develop ~/nix-config#rust  --command zsh";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "jeffreytse/zsh-vi-mode"; }
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
      ];
    };

    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];

    # Profiling
    # initExtraFirst = "zmodload zsh/zprof";

    initExtraBeforeCompInit = ''
      fpath+=$HOME/nix-config/shells/rust/comp
    '';

    initExtra = ''
      source ~/nix-config/modules/shell/.p10k.zsh
    '';

    # initExtra = ''
    #   source ~/nix-config/.p10k.zsh \n
    #   zprof
    # '';
  };
}
