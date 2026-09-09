{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  nvimSocketContract = import ./nvim-socket-contract.nix;
  nvimSession = pkgs.writeShellApplication {
    name = "nvim-session";
    runtimeInputs = [
      pkgs.neovim
      pkgs-unstable.tmux
    ];
    text = nvimSocketContract.shell + builtins.readFile ./scripts/nvim-session.sh;
  };
in
{
  # In order for .profile being updated.
  programs.bash = {
    enable = true;
  };

  home = {
    packages = with pkgs; [
      nix-zsh-completions
      nvimSession
    ];
    shell.enableZshIntegration = true;
  };

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
      gd = "command -v godiff >/dev/null && godiff || git diff";
      v = "nvim-session";
      rustshell = "nix develop ${inputs.self}#rust --command zsh";
      ocamlshell = "nix develop ${inputs.self}#ocaml --command zsh";
      gls = "git gls";
      glsr = "git glsr";
      glsl = "git glsl";
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "git";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/git/git.plugin.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Profiling
    # initExtraFirst = "zmodload zsh/zprof";

    initContent = "source ${./.p10k.zsh}";
  };
}
