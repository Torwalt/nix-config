{ pkgs, pkgs-unstable, ... }:
let
  openNvimUrl = pkgs.writeShellApplication {
    name = "open-nvim-url";
    runtimeInputs = with pkgs; [
      neovim
      python3
    ];

    text = ''
            socket="''${XDG_RUNTIME_DIR:?}/nvim-main.sock"
            url="''${1:-}"

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
        if-shell -F '#{!=:#{copy_cursor_hyperlink},}' \
          'run-shell "${openNvimUrl}/bin/open-nvim-url \"#{copy_cursor_hyperlink}\""' \
          'display-message "No hyperlink under cursor"'

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
