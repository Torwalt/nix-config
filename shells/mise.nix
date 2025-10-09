{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSUserEnv {
    name = "mise-fhs";
    # tools available *inside* the FHS shell
    targetPkgs = pkgs:
      with pkgs; [
        zsh
        curl
        cacert # TLS certs for curl
        git
        # add whatever you want available inside FHS:
        # nodejs_22 pnpm binaryen
      ];

    # Start a login zsh inside the FHS env
    runScript = "zsh";

    # Runs on shell entry (like a shellHook, but for buildFHSUserEnv)
    profile = ''
      # Put user-local bin first so a freshly installed mise is found
      export PATH="$HOME/.local/bin:$PATH"

      # Optional: keep mise data per-repo instead of polluting global home
      # export MISE_DATA_DIR="$PWD/.mise-data"

      if ! command -v mise >/dev/null 2>&1; then
        echo "[devShell] Installing mise to \$HOME/.local/bin via mise.run (impure)…"
        mkdir -p "$HOME/.local/bin"
        curl -fsSL https://mise.run | sh
      fi

      # Activate mise for the current shell
      if [ -n "$ZSH_NAME" ]; then
        eval "$("$HOME/.local/bin/mise" activate zsh)"
      else
        eval "$("$HOME/.local/bin/mise" activate bash)"
      fi

      fix_ssh () {
        mkdir -p "$HOME/.ssh"
        # Materialize config if it points into the store
        if [ -L "$HOME/.ssh/config" ] && readlink -f "$HOME/.ssh/config" | grep -q '^/nix/store/'; then
          cp --dereference "$HOME/.ssh/config" "$HOME/.ssh/config.fhs"
          chmod 600 "$HOME/.ssh/config.fhs"
          export GIT_SSH_COMMAND="ssh -F $HOME/.ssh/config.fhs"
        fi

        # Materialize common key names if they’re symlinks into the store
        for k in id_ed25519 id_rsa; do
          if [ -L "$HOME/.ssh/$k" ] && readlink -f "$HOME/.ssh/$k" | grep -q '^/nix/store/'; then
            cp --dereference "$HOME/.ssh/$k" "$HOME/.ssh/$k.fhs"
            chmod 600 "$HOME/.ssh/$k.fhs"
            # If your config references the original name, also export:
            #   export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
            # Nothing else needed; ssh will pick the key via config or default name.
          fi
        done
      }
      fix_ssh
    '';
  };
in fhs.env

