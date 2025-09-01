{ ... }: {

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";

    aliases = {
      gls = "!f(){ git rev-list --reverse \${1:-master}..HEAD | head -n1; }; f";
      glsr = ''
        !f(){ base="$(git merge-base --fork-point "''${1:-master}" HEAD || git merge-base "''${1:-master}" HEAD)"; [ -n "$base" ] && git rebase -i "''${base}"; }; f'';
      glsl = ''
        !f(){ base="$(git merge-base --fork-point "''${1:-master}" HEAD || git merge-base "''${1:-master}" HEAD)"; git log "''${base}..HEAD" --reverse --pretty=format:"## %s%n%n%b%n"; }; f'';
    };

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

    lfs.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = { enable = true; };

  services.dunst = {
    enable = true;
    settings.global.monitor = 1;
  };

  programs.btop = { enable = true; };
}
