socket=""

if [[ -n "${TMUX:-}" ]]; then
  session="$(tmux display-message -p '#S')"
  socket="${XDG_RUNTIME_DIR:?}/nvim-tmux-${session}.sock"
  tmux set-option -t "$session" @nvim_socket "$socket"
else
  socket="${XDG_RUNTIME_DIR:?}/nvim-main.sock"
fi

nvim --listen "$socket" "$@"
