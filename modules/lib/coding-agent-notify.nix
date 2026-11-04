{ pkgs, tmux }:

let
  agentQueue = import ./agent-queue.nix { inherit pkgs tmux; };
in
pkgs.writeShellApplication {
  name = "coding-agent-notify";
  runtimeInputs = [
    agentQueue
    pkgs.libnotify
    tmux
  ];
  text = ''
    app_name="''${1:-Coding agent}"
    message="''${2:-Task finished}"
    summary="$app_name"

    if [ -n "''${TMUX:-}" ] && [ -n "''${TMUX_PANE:-}" ]; then
      agent-queue push "$app_name" "$message"

      tmux_context="$(tmux display-message -p -t "$TMUX_PANE" \
        '#{session_name}:#{window_index}.#{pane_index} (#{window_name})' 2>/dev/null || true)"
      position="$(agent-queue position "$TMUX_PANE")"

      if [ -n "$tmux_context" ]; then
        summary="$tmux_context · $app_name"
      fi
      if [ -n "$position" ]; then
        message="$message · queue $position (Alt+A: next)"
      fi
    fi

    notify-send \
      --app-name="$app_name" \
      "$summary" \
      "$message"
  '';
}
