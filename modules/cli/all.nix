{ ... }: {

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Alexander Dadiani";
        email = "alexdadiani1994@gmail.com";
      };

      # IMPORTANT: section is "alias", not "aliases"
      alias = {
        gls =
          "!f(){ git rev-list --reverse \${1:-master}..HEAD | head -n1; }; f";
        glsr = ''
          !f(){ base="$(git merge-base --fork-point "''${1:-master}" HEAD || git merge-base "''${1:-master}" HEAD)"; [ -n "$base" ] && git rebase -i "''${base}"; }; f'';
        glsl = ''
          !f(){ base="$(git merge-base --fork-point "''${1:-master}" HEAD || git merge-base "''${1:-master}" HEAD)"; git log "''${base}..HEAD" --reverse --pretty=format:"## %s%n%n%b%n"; }; f'';
      };

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # Git-side delta config (only delta’s own knobs)
      delta = {
        navigate = true;
        line-numbers = true;
        paging = "always";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };

    ignores = [ ".git" ];
    lfs.enable = true;
  };

  # IMPORTANT: this is what actually wires delta into git as pager/diff filter
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      paging = "always";
    };
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
