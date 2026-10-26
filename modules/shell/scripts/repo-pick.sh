# Repo picker. Prints the chosen checkout, worktrees included; the rf shell
# function cds there.

cd "$HOME"

fzf_args=(
  --preview='git -C {} -c color.status=always status -sb; echo; git -C {} log --oneline --decorate --color=always -10'
)
if [[ -n "${1:-}" ]]; then
  fzf_args+=(--query="$1" --select-1)
fi

selection="$(
  fd --hidden --no-ignore --prune \
    --exclude node_modules --exclude replay-builds \
    --format '{//}' '^\.git$' repos nix-config |
    sort |
    fzf "${fzf_args[@]}"
)" || exit 0

printf '%s\n' "$HOME/$selection"
