{ pkgs, pkgs-unstable, ... }:
let
  tmuxOpenNvimHyperlink = pkgs.writeShellApplication {
    name = "tmux-open-nvim-hyperlink";
    runtimeInputs = with pkgs; [
      neovim
      python3
      pkgs-unstable.tmux
    ];
    text = builtins.readFile ./scripts/tmux-open-nvim-hyperlink.sh;
  };
in
{
  home.packages = [
    tmuxOpenNvimHyperlink
  ];

  programs.tmux = {
    enable = true;
    package = pkgs-unstable.tmux;
    escapeTime = 0;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";
    extraConfig = ''
      # session fzf to switch to
      bind-key f run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh switch"

      bind-key -T copy-mode-vi o \
        run-shell "${tmuxOpenNvimHyperlink}/bin/tmux-open-nvim-hyperlink '#{pane_id}' '#{copy_cursor_x}' '#{pane_width}'"

      set -g allow-passthrough on
      set -g copy-mode-line-numbers relative
      set -g copy-mode-line-number-style "fg=colour240"
      set -g copy-mode-current-line-number-style "fg=yellow,bold"
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'
      set -as terminal-features ',xterm-kitty:hyperlinks'
    '';

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.yank
      tmuxPlugins.tmux-fzf
    ];
  };
}
