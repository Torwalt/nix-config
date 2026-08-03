socket=""

if [[ -n "${TMUX:-}" ]]; then
  session="$(tmux display-message -p '#S')"
  socket="$(nvim_tmux_session_socket "$session")"
  tmux set-option -t "$session" "$nvim_tmux_socket_option" "$socket"
else
  socket="$(nvim_main_socket)"
fi

nvim --listen "$socket" "$@"
