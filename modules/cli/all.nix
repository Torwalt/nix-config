{ pkgs, ... }:
let
  gitBase = pkgs.writeShellApplication {
    name = "git-base";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-base.sh;
  };
in
{
  home.packages = [
    pkgs.godiff
    pkgs.spool
    gitBase
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Alexander Dadiani";
        email = "alexdadiani1994@gmail.com";
      };

      alias = {
        gls = ''!f(){ base="$(git base "$@")" && git rev-list --reverse "$base..HEAD" | head -n1; }; f'';
        glsr = ''!f(){ base="$(git base "$@")" && git rebase -i "$base"; }; f'';
        glsl = ''!f(){ base="$(git base "$@")" && git log --reverse --pretty=format:"## %s%n%n%b%n" "$base..HEAD"; }; f'';
      };

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      delta = {
        hyperlinks = true;
        hyperlinks-file-link-format = "file://{path}#{line}";
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      hyperlinks = true;
      hyperlinks-file-link-format = "file://{path}#{line}";
      navigate = true;
      line-numbers = true;
      paging = "always";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        pagers = [ { pager = "delta --paging=never --line-numbers"; } ];
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
  };

  programs.btop = {
    enable = true;
  };
}
