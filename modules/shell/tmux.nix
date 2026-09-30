{ pkgs, pkgs-unstable, ... }:
let
  nvimSocketContract = import ./nvim-socket-contract.nix;
  tmuxOpenNvimHyperlink = pkgs.writeShellApplication {
    name = "tmux-open-nvim-hyperlink";
    runtimeInputs = with pkgs; [
      neovim
      python3
      pkgs-unstable.tmux
    ];
    text = nvimSocketContract.shell + builtins.readFile ./scripts/tmux-open-nvim-hyperlink.sh;
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

      # Treat both uppercase and Ctrl-z like the default pane zoom binding.
      bind-key Z resize-pane -Z
      bind-key C-z resize-pane -Z

      # spool over the current pane: read its Claude session, q goes back.
      # run-shell expands the pane formats; display-popup does not in -w/-h.
      bind-key v run-shell -b "${pkgs-unstable.tmux}/bin/tmux display-popup -c '#{client_name}' -t '#{pane_id}' -E -B -x P -y P -w #{pane_width} -h #{pane_height} -d '#{pane_current_path}' '${pkgs.spool}/bin/spool --popup --pane #{pane_id}'"

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
