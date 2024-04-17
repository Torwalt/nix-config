{ pkgs, ... }: {
  # In order for .profile being updated.
  programs.bash = { enable = true; };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
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
      nix-switch = "home-manager switch --flake ~/nix-config/#ada@ada-machine";
      nix-upgrade = "sudo nixos-rebuild --flake ~/nix-config/#adasys switch";
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
    initExtra = ''
      source ~/nix-config/modules/shell/.p10k.zsh \n
    '';

    # initExtra = ''
    #   source ~/nix-config/.p10k.zsh \n
    #   zprof
    # '';
  };
}
