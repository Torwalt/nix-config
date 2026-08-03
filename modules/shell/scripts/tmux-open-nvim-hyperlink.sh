resolve_socket() {
  local pane="${1:?}"
  local session=""
  local socket=""
  local fallback=""

  session="$(tmux display-message -p -t "$pane" '#{session_name}')"
  fallback="$(nvim_tmux_session_socket "$session")"
  socket="$(tmux show-option -qv -t "$session" "$nvim_tmux_socket_option")"

  if [[ -n "$socket" && -S "$socket" ]]; then
    printf '%s\n' "$socket"
    return
  fi

  printf '%s\n' "$fallback"
}

open_url() {
  local url="${1:-}"
  local socket="${2:?}"
  local target=""
  local path=""
  local line=""

  if [[ -z "$url" ]]; then
    exit 0
  fi

  if [[ ! -S "$socket" ]]; then
    printf 'Neovim socket not found: %s\n' "$socket" >&2
    exit 1
  fi

  case "$url" in
    file://*) ;;
    *)
      printf 'Unsupported URL: %s\n' "$url" >&2
      exit 1
      ;;
  esac

  target="${url#file://}"

  if [[ "$target" == *"#"* ]]; then
    path="${target%%#*}"
    line="${target##*#}"
  else
    path="$target"
    line=1
  fi

  if [[ ! "$line" =~ ^[0-9]+$ ]]; then
    line=1
  fi

  path="$(
    python3 - "$path" <<'PY'
import sys
import urllib.parse

print(urllib.parse.unquote(sys.argv[1]))
PY
  )"

  if [[ ! -e "$path" ]]; then
    printf 'File does not exist: %s\n' "$path" >&2
    exit 1
  fi

  nvim --server "$socket" --remote "$path"
  nvim --server "$socket" --remote-send "<C-\\><C-N>:${line}<CR>zz"
}

open_tmux_copy_row() {
  local pane="${1:?}"
  local original_x="${2:-0}"
  local width="${3:-0}"
  local url=""
  local x=0

  if [[ ! "$original_x" =~ ^[0-9]+$ ]]; then
    original_x=0
  fi

  if [[ ! "$width" =~ ^[0-9]+$ ]] || ((width == 0)); then
    width="$(tmux display-message -p -t "$pane" '#{pane_width}')"
  fi

  tmux send-keys -t "$pane" -X start-of-line

  for ((x = 0; x < width; x++)); do
    url="$(tmux display-message -p -t "$pane" '#{copy_cursor_hyperlink}')"
    if [[ -n "$url" ]]; then
      break
    fi

    tmux send-keys -t "$pane" -X cursor-right
  done

  tmux send-keys -t "$pane" -X start-of-line
  if ((original_x > 0)); then
    tmux send-keys -t "$pane" -N "$original_x" -X cursor-right
  fi

  if [[ -z "$url" ]]; then
    tmux display-message -t "$pane" "No hyperlink on row"
    exit 0
  fi

  open_url "$url" "$(resolve_socket "$pane")"
}

open_tmux_copy_row "$@"
