{ pkgs, tmux }:

pkgs.writeShellApplication {
  name = "coding-agent-notify";
  runtimeInputs = with pkgs; [
    libnotify
    tmux
  ];
  text = ''
    app_name="''${1:-Coding agent}"
    message="Task finished"

    if [ -n "''${TMUX:-}" ]; then
      tmux_target=()
      if [ -n "''${TMUX_PANE:-}" ]; then
        tmux_target=(-t "$TMUX_PANE")
      fi

      tmux_context="$(tmux display-message -p "''${tmux_target[@]}" \
        '#{session_name}:#{window_index}.#{pane_index} (#{window_name})' 2>/dev/null || true)"

      if [ -n "$tmux_context" ]; then
        message="Task finished · tmux $tmux_context"
      fi
    fi

    notify-send \
      --app-name="$app_name" \
      "$app_name" \
      "$message"
  '';
}
