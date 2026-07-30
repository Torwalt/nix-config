{ pkgs, pkgs-unstable, ... }:
let
  openNvimUrl = pkgs.writeShellApplication {
    name = "open-nvim-url";
    runtimeInputs = with pkgs; [
      neovim
      python3
      pkgs-unstable.tmux
    ];

    text = ''
            socket="''${XDG_RUNTIME_DIR:?}/nvim-main.sock"

            open_url() {
              local url="''${1:-}"

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

              target="''${url#file://}"

              if [[ "$target" == *"#"* ]]; then
                path="''${target%%#*}"
                line="''${target##*#}"
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
              nvim --server "$socket" --remote-send "<C-\\><C-N>:''${line}<CR>zz"
            }

            open_tmux_copy_row() {
              local pane="''${1:?}"
              local original_x="''${2:-0}"
              local width="''${3:-0}"
              local url=""

              if [[ ! "$original_x" =~ ^[0-9]+$ ]]; then
                original_x=0
              fi

              if [[ ! "$width" =~ ^[0-9]+$ ]] || (( width == 0 )); then
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
              if (( original_x > 0 )); then
                tmux send-keys -t "$pane" -N "$original_x" -X cursor-right
              fi

              if [[ -z "$url" ]]; then
                tmux display-message -t "$pane" "No hyperlink on row"
                exit 0
              fi

              open_url "$url"
            }

            open_tmux_copy_row "$@"
    '';
  };
in
{
  home.packages = [
    openNvimUrl
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
        run-shell "${openNvimUrl}/bin/open-nvim-url '#{pane_id}' '#{copy_cursor_x}' '#{pane_width}'"

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
