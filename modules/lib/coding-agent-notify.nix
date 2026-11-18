{ pkgs, tmux }:

let
  agentQueue = import ./agent-queue.nix { inherit pkgs tmux; };
  agentHook = import ./agent-hook.nix { inherit pkgs; };
in
pkgs.writeShellApplication {
  name = "coding-agent-notify";
  runtimeInputs = [
    agentHook
    agentQueue
    pkgs.libnotify
    tmux
  ];
  text = ''
    app_name="''${1:-Coding agent}"
    message="''${2:-Task finished}"
    summary="$app_name"

    # The one gate for both the queue and the notification. Background work
    # wakes the session again, and the turn that ends with nothing left in
    # flight is the one that notifies.
    if agent-hook paused_for_background; then
      exit 0
    fi

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
