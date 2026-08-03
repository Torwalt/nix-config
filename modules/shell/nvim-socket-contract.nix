{
  shell = ''
    nvim_tmux_socket_option="@nvim_socket"

    nvim_main_socket() {
      printf '%s\n' "''${XDG_RUNTIME_DIR:?}/nvim-main.sock"
    }

    nvim_tmux_session_socket() {
      local session="''${1:?}"
      printf '%s\n' "''${XDG_RUNTIME_DIR:?}/nvim-tmux-''${session}.sock"
    }
  '';
}
