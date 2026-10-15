# Branch picker. A branch checked out in another worktree is checked out
# detached, so its last commit shows here without touching that worktree.

here="$(git rev-parse --show-toplevel)"
old="$(git rev-parse HEAD)"

declare -A local_branches=()
while read -r name; do
  local_branches[$name]=1
done < <(git for-each-ref --format='%(refname:short)' refs/heads)

rows=()
while IFS=$'\t' read -r ref name worktree; do
  case "$ref" in
    refs/remotes/*/HEAD) continue ;;
    refs/remotes/*) [[ -n "${local_branches[${ref#refs/remotes/*/}]:-}" ]] && continue ;;
  esac
  label="$name"
  [[ -n "$worktree" ]] && label+="  [${worktree##*/}]"
  rows+=("$label"$'\t'"$name"$'\t'"$worktree")
done < <(
  git for-each-ref --sort=-committerdate \
    --format='%(refname)%09%(refname:short)%09%(worktreepath)' \
    refs/heads refs/remotes
)

fzf_args=(
  --delimiter=$'\t'
  --with-nth=1
  --preview='git log --oneline --decorate --color=always -10 {2}; [ -z {3} ] || { echo; git -C {3} -c color.status=always status -sb; }'
)
if [[ -n "${1:-}" ]]; then
  fzf_args+=(--query="$1" --select-1)
fi

selection="$(printf '%s\n' "${rows[@]}" | fzf "${fzf_args[@]}")" || exit 0
IFS=$'\t' read -r _ branch worktree <<<"$selection"

if [[ "$worktree" == "$here" ]]; then
  echo "already on $branch"
  exit 0
elif [[ -n "$worktree" ]]; then
  git switch --detach "$branch"
elif git show-ref --verify --quiet "refs/heads/$branch"; then
  git switch "$branch"
else
  git switch --track "$branch"
fi

changes="$(
  git diff --name-status "$old" HEAD -- \
    '*go.mod' '*lock.yaml' '*-lock.json' '*.lock' '*migrations/*'
)"
if [[ -n "$changes" ]]; then
  printf '\nDependencies or migrations changed:\n%s\n' "$changes"
fi
