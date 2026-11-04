# agent-queue: FIFO of tmux panes whose coding agent waits for the user.
#
# One line per pane: <epoch>\t<pane id>\t<app>\t<message>. A pane holds its
# place while it stays queued, so the agent that has waited longest is next.
# Labels (session:window) are read from tmux on display, and panes that no
# longer exist are dropped whenever the queue is read. The order lives only
# in this file; notifications merely announce it. `pick` uses the rofi on
# PATH so it shares the desktop's rofi theme.

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/agent-queue"
queue="$state_dir/queue"
waybar_signal=10

mkdir -p "$state_dir"
touch "$queue"

usage() {
  cat <<'EOF'
usage: agent-queue <command>
  push APP MESSAGE  queue $TMUX_PANE (keeps its place if already queued)
  drop [PANE]       remove PANE (default $TMUX_PANE) from the queue
  next              jump to the oldest waiting pane and remove it
  pick              choose a waiting pane with rofi and jump to it
  position [PANE]   print "N/TOTAL" for PANE (default $TMUX_PANE)
  list              print the queue, oldest first
  waybar            print the queue as waybar JSON
  clear             empty the queue
EOF
}

with_lock() {
  exec 9>"$state_dir/lock"
  flock 9
}

refresh_waybar() {
  pkill -RTMIN+"$waybar_signal" waybar 2>/dev/null || true
}

live_panes() {
  tmux list-panes -a -F '#{pane_id}' 2>/dev/null || true
}

# Pane ids only mean something within one tmux server: a new server hands
# out %0, %1, … again. The queue belongs to the server that started at
# server_start; a different server starts it empty.
check_server() {
  local current stored=""
  current="$(tmux list-sessions -F '#{start_time}' 2>/dev/null | head -n 1 || true)"
  [ -f "$state_dir/server" ] && stored="$(<"$state_dir/server")"
  if [ "$current" != "$stored" ]; then
    : >"$queue"
    printf '%s\n' "$current" >"$state_dir/server"
  fi
}

# Rewrite the queue without panes that tmux no longer knows.
prune() {
  local live tmp
  check_server
  live="$(live_panes)"
  tmp="$(mktemp "$state_dir/queue.XXXXXX")"
  awk -F '\t' -v live="$live" '
    BEGIN { n = split(live, ids, "\n"); for (i = 1; i <= n; i++) alive[ids[i]] = 1 }
    alive[$2]
  ' "$queue" >"$tmp"
  mv "$tmp" "$queue"
}

remove_pane() {
  local pane="$1" tmp
  tmp="$(mktemp "$state_dir/queue.XXXXXX")"
  awk -F '\t' -v pane="$pane" '$2 != pane' "$queue" >"$tmp"
  mv "$tmp" "$queue"
}

label() {
  tmux display-message -p -t "$1" \
    '#{session_name}:#{window_index}.#{pane_index} (#{window_name})' 2>/dev/null || printf '%s' "$1"
}

age() {
  local secs=$(($(date +%s) - $1))
  if ((secs < 60)); then
    printf '%ds' "$secs"
  elif ((secs < 3600)); then
    printf '%dm' $((secs / 60))
  else
    printf '%dh%02dm' $((secs / 3600)) $((secs % 3600 / 60))
  fi
}

position() {
  local pane="$1"
  awk -F '\t' -v pane="$pane" '
    $2 == pane { pos = NR }
    END { if (pos) printf "%d/%d\n", pos, NR }
  ' "$queue"
}

# The Hyprland window that hosts a tmux client: walk up from the client's
# pid until a process owns a window.
focus_terminal() {
  local pid="$1" windows address
  command -v hyprctl >/dev/null || return 0
  windows="$(hyprctl clients -j 2>/dev/null)" || return 0
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    address="$(jq -r --argjson pid "$pid" \
      'map(select(.pid == $pid)) | first | .address // empty' <<<"$windows")"
    if [ -n "$address" ]; then
      hyprctl dispatch focuswindow "address:$address" >/dev/null
      return 0
    fi
    pid="$(awk '{ print $4 }' "/proc/$pid/stat" 2>/dev/null || true)"
  done
}

cmd_push() {
  local app="${1:-Coding agent}" message="${2:-Waiting}" pane="${TMUX_PANE:-}"
  [ -n "$pane" ] || return 0
  # Tabs and newlines would break the line format.
  message="${message//[$'\t\n']/ }"
  app="${app//[$'\t\n']/ }"

  with_lock
  check_server
  if awk -F '\t' -v pane="$pane" '$2 == pane { found = 1 } END { exit !found }' "$queue"; then
    # Keep the original place; show the latest reason.
    local tmp
    tmp="$(mktemp "$state_dir/queue.XXXXXX")"
    awk -F '\t' -v OFS='\t' -v pane="$pane" -v app="$app" -v msg="$message" \
      '$2 == pane { $3 = app; $4 = msg } { print }' "$queue" >"$tmp"
    mv "$tmp" "$queue"
  else
    printf '%s\t%s\t%s\t%s\n' "$(date +%s)" "$pane" "$app" "$message" >>"$queue"
  fi
  refresh_waybar
}

cmd_drop() {
  local pane="${1:-${TMUX_PANE:-}}"
  [ -n "$pane" ] || return 0
  # Fast path: hooks call this on every prompt and tool call.
  grep -qF "	$pane	" "$queue" || return 0
  with_lock
  remove_pane "$pane"
  refresh_waybar
}

cmd_next() {
  with_lock
  prune
  local line
  line="$(head -n 1 "$queue")"
  if [ -z "$line" ]; then
    refresh_waybar
    notify-send --app-name=agent-queue --expire-time=2000 "Agent queue" "Nothing is waiting"
    return 0
  fi

  jump_to "$(cut -f 2 <<<"$line")"
}

# Pick any queued pane with rofi, oldest on top.
cmd_pick() {
  local entries choice pane
  entries="$(snapshot)"
  if [ -z "$entries" ]; then
    notify-send --app-name=agent-queue --expire-time=2000 "Agent queue" "Nothing is waiting"
    return 0
  fi
  choice="$(format_entries <<<"$entries" |
    rofi -dmenu -i -format i -no-custom -p "agent queue")" || return 0
  [ -n "$choice" ] || return 0

  # Resolve the choice against what rofi showed, not the live queue, which
  # may have changed meanwhile.
  pane="$(awk -F '\t' -v n="$((choice + 1))" 'NR == n { print $2 }' <<<"$entries")"
  [ -n "$pane" ] || return 0
  with_lock
  jump_to "$pane"
}

# Remove PANE from the queue, then show it in the most recent tmux client
# and focus the terminal around that client. Expects the lock to be held.
jump_to() {
  local pane="$1"
  remove_pane "$pane"
  refresh_waybar

  # The client used most recently is the one in front of the user.
  local client client_pid
  read -r _ client client_pid < <(
    tmux list-clients -F '#{client_activity} #{client_name} #{client_pid}' | sort -rn | head -n 1
  ) || true

  if [ -n "${client:-}" ]; then
    tmux switch-client -c "$client" -t "$pane"
  fi
  tmux select-window -t "$pane"
  tmux select-pane -t "$pane"

  if [ -n "${client_pid:-}" ]; then
    focus_terminal "$client_pid"
  fi
}

# The pruned queue as raw lines; the lock is held only inside the subshell.
snapshot() {
  (
    with_lock
    prune
    cat "$queue"
  )
}

# Raw queue lines on stdin, one readable line each on stdout.
format_entries() {
  local n=0 epoch pane app message
  while IFS=$'\t' read -r epoch pane app message; do
    [ -n "$pane" ] || continue
    n=$((n + 1))
    printf '%d. %s  %s — %s (%s ago)\n' "$n" "$(label "$pane")" "$app" "$message" "$(age "$epoch")"
  done
}

cmd_list() {
  snapshot | format_entries
}

cmd_waybar() {
  local entries oldest epoch pane app message
  entries="$(snapshot)"
  if [ -z "$entries" ]; then
    printf '{"text":"","tooltip":"No agent is waiting","class":"empty"}\n'
    return 0
  fi
  local count
  count="$(wc -l <<<"$entries")"
  IFS=$'\t' read -r epoch pane app message <<<"$entries"
  oldest="$(label "$pane" | cut -d ' ' -f 1)"
  jq -cn --arg text "󰂚 $count · $oldest $(age "$epoch")" \
    --arg tooltip "$(format_entries <<<"$entries")" \
    '{text: $text, tooltip: $tooltip, class: "waiting"}'
}

cmd_clear() {
  with_lock
  : >"$queue"
  refresh_waybar
}

command="${1:-}"
[ $# -gt 0 ] && shift
case "$command" in
  push) cmd_push "$@" ;;
  drop) cmd_drop "$@" ;;
  next) cmd_next ;;
  pick) cmd_pick ;;
  position) position "${1:-${TMUX_PANE:-}}" ;;
  list) cmd_list ;;
  waybar) cmd_waybar ;;
  clear) cmd_clear ;;
  *) usage >&2; exit 2 ;;
esac
