{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    escapeTime = 0;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.yank
    ];
  };
}
