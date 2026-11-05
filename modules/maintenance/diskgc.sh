usage() {
  cat <<'EOF'
Usage: diskgc [report]
       diskgc apply CATEGORY... | all

Reports disk space that can be reclaimed without losing work, with the
command that reclaims each category. `apply` runs the given categories,
asking before each one. `all` runs them in the order below.

Categories:
  worktrees      linked Git worktrees without changes whose commit is merged
                 or kept on another ref, idle for a day and not in use
  tmp            entries in the expiring directories untouched for the
                 configured number of days, without sockets or Git checkouts
  docker-cache   the Docker build cache
  docker-images  untagged images and unused anonymous volumes
  go-cache       the Go build cache
  pnpm           pnpm store packages no project references
  nix            generations beyond the retained count, then unreferenced
                 store paths (nixup clean)

Reported only: Docker volumes over 1 GB and large directories in ~/.cache
and ~/.local/share.
EOF
}

die() {
  printf 'diskgc: %s\n' "$*" >&2
  exit 1
}

section() {
  printf '\n==> %s\n' "$*"
}

human() {
  numfmt --to=iec --suffix=B "${1:-0}"
}

disk_bytes() {
  { du -s -B1 --one-file-system "$@" 2>/dev/null || true; } | awk '{ sum += $1 } END { print sum + 0 }'
}

contains() {
  local needle=$1 item
  shift
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

confirm() {
  local reply
  read -rp "$1 [y/N] " reply
  [ "$reply" = y ] || [ "$reply" = Y ]
}

max_age_minutes=$((DISKGC_MAX_AGE_DAYS * 24 * 60))
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# Paths that a running process has as its working directory or holds open.
load_in_use() {
  [ -f "$work_dir/in-use" ] && return 0
  find /proc/[0-9]*/cwd /proc/[0-9]*/fd -maxdepth 1 -printf '%l\n' 2>/dev/null |
    grep '^/' | sort -u >"$work_dir/in-use" || true
}

in_use() {
  awk -v p="$1" '$0 == p || index($0, p "/") == 1 { found = 1; exit } END { exit !found }' \
    "$work_dir/in-use"
}

main_checkouts() {
  local root dir
  local -a roots
  IFS=: read -ra roots <<<"$DISKGC_REPO_ROOTS"
  for root in "${roots[@]}"; do
    for dir in "$root"/*/; do
      [ -d "$dir.git" ] && printf '%s\n' "${dir%/}"
    done
  done
}

default_remote_ref() {
  local repo=$1 ref
  ref="$(git -C "$repo" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)" && {
    printf '%s\n' "$ref"
    return 0
  }
  for ref in origin/master origin/main; do
    git -C "$repo" rev-parse -q --verify "$ref" >/dev/null && {
      printf '%s\n' "$ref"
      return 0
    }
  done
  return 1
}

merged_pr_heads() {
  local repo=$1 branch=$2
  command -v gh >/dev/null || return 0
  [[ "$(git -C "$repo" remote get-url origin 2>/dev/null)" == *github.com* ]] || return 0
  (cd "$repo" && gh pr list --head "$branch" --state merged --json headRefOid \
    --jq '.[].headRefOid' 2>/dev/null) || true
}

# Why a worktree may go, or nothing when it stays. Sets kept_reason otherwise.
removal_reason() {
  local repo=$1 wt=$2 head=$3 branch=$4 base last_move pr_heads pr_head
  kept_reason=""
  if in_use "$wt"; then
    kept_reason="in use"
    return 0
  fi
  if [ -n "$(git -C "$wt" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    kept_reason="changes"
    return 0
  fi
  last_move="$(git -C "$wt" reflog -1 --date=unix --format=%gd HEAD 2>/dev/null | tr -dc 0-9)"
  [ -n "$last_move" ] || last_move="$(git -C "$wt" log -1 --format=%ct HEAD)"
  if [ $(($(date +%s) - ${last_move:-0})) -lt 86400 ]; then
    kept_reason="active today"
    return 0
  fi
  if base="$(default_remote_ref "$repo")" &&
    git -C "$repo" merge-base --is-ancestor "$head" "$base"; then
    printf 'in %s' "$base"
    return 0
  fi
  if [ -n "$branch" ]; then
    pr_heads="$(merged_pr_heads "$repo" "$branch")"
    for pr_head in $pr_heads; do
      if git -C "$repo" merge-base --is-ancestor "$head" "$pr_head" 2>/dev/null; then
        printf 'PR merged'
        return 0
      fi
    done
  fi
  if [ -z "$branch" ]; then
    local ref
    ref="$(git -C "$repo" for-each-ref --contains "$head" --count=1 \
      --format='%(refname:short)' refs/heads refs/remotes)"
    if [ -n "$ref" ]; then
      printf 'detached, commit on %s' "$ref"
      return 0
    fi
  fi
  kept_reason="unmerged"
}

# Writes repo, path, bytes and reason per removable worktree to $work_dir/worktrees.
scan_worktrees() {
  local repo line wt head branch reason
  load_in_use
  : >"$work_dir/worktrees"
  : >"$work_dir/worktrees-kept"
  : >"$work_dir/worktrees-prunable"
  while IFS= read -r repo; do
    wt="" head="" branch=""
    while IFS= read -r line; do
      case "$line" in
        "worktree "*) wt="${line#worktree }" head="" branch="" ;;
        "HEAD "*) head="${line#HEAD }" ;;
        "branch "*) branch="${line#branch refs/heads/}" ;;
        locked*) printf '%s\tlocked\n' "$wt" >>"$work_dir/worktrees-kept" && wt="" ;;
        prunable*) printf '%s\n' "$wt" >>"$work_dir/worktrees-prunable" && wt="" ;;
        "")
          if [ -n "$wt" ] && [ "$wt" != "$repo" ]; then
            reason="$(removal_reason "$repo" "$wt" "$head" "$branch"; printf '|%s' "$kept_reason")"
            if [ -n "${reason%%|*}" ]; then
              printf '%s\t%s\t%s\t%s\n' "$repo" "$wt" "$(disk_bytes "$wt")" "${reason%%|*}" \
                >>"$work_dir/worktrees"
            else
              printf '%s\t%s\n' "$wt" "${reason#*|}" >>"$work_dir/worktrees-kept"
            fi
          fi
          wt=""
          ;;
      esac
    done < <(git -C "$repo" worktree list --porcelain; printf '\n')
  done < <(main_checkouts)
}

report_worktrees() {
  local total
  section "worktrees"
  scan_worktrees
  total="$(awk -F'\t' '{ sum += $3 } END { print sum + 0 }' "$work_dir/worktrees")"
  awk -F'\t' '{ printf "%s\t%s  (%s)\n", $3, $2, $4 }' "$work_dir/worktrees" |
    numfmt --field=1 --to=iec --suffix=B | sed 's/^/  /'
  if [ -s "$work_dir/worktrees-prunable" ]; then
    printf '  %s registrations whose directory is gone\n' "$(wc -l <"$work_dir/worktrees-prunable")"
  fi
  printf '  kept: %s\n' "$(cut -f2 "$work_dir/worktrees-kept" | sort | uniq -c |
    awk '{ c = $1; $1 = ""; printf "%s%s %s", sep, substr($0, 2), c; sep = ", " }')"
  printf '  reclaimable: %s\n' "$(human "$total")"
  [ -s "$work_dir/worktrees" ] && printf '  run: diskgc apply worktrees\n'
  return 0
}

apply_worktrees() {
  local repo wt
  report_worktrees
  [ -s "$work_dir/worktrees" ] || [ -s "$work_dir/worktrees-prunable" ] || return 0
  confirm "Remove these worktrees? Their branches stay." || return 0
  while IFS=$'\t' read -r repo wt _ _; do
    git -C "$repo" worktree remove "$wt" && printf 'removed %s\n' "$wt"
  done <"$work_dir/worktrees"
  while IFS= read -r repo; do
    git -C "$repo" worktree prune
  done < <(main_checkouts)
}

# Writes path and bytes per expired entry to $work_dir/tmp.
scan_tmp() {
  local pattern dir entry
  local -a patterns dirs=()
  load_in_use
  : >"$work_dir/tmp"
  IFS=: read -ra patterns <<<"$DISKGC_EXPIRING_DIRS"
  for pattern in "${patterns[@]}"; do
    # shellcheck disable=SC2086
    for dir in $pattern; do
      [ -d "$dir" ] && dirs+=("$dir")
    done
  done
  for dir in "${dirs[@]}"; do
    while IFS= read -r -d '' entry; do
      contains "$entry" "${dirs[@]}" && continue
      in_use "$entry" && continue
      [ -n "$(find "$entry" -mmin "-$max_age_minutes" -print -quit 2>/dev/null)" ] && continue
      [ -n "$(find "$entry" \( -type s -o -name .git -o ! -user "$USER" \) -print -quit 2>/dev/null)" ] && continue
      printf '%s\t%s\n' "$entry" "$(disk_bytes "$entry")" >>"$work_dir/tmp"
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -user "$USER" -print0 2>/dev/null)
  done
}

report_tmp() {
  local total
  section "tmp (untouched for $DISKGC_MAX_AGE_DAYS days)"
  scan_tmp
  total="$(awk -F'\t' '{ sum += $2 } END { print sum + 0 }' "$work_dir/tmp")"
  sort -t$'\t' -k2,2nr "$work_dir/tmp" | awk 'NR <= 10' |
    awk -F'\t' '{ printf "%s\t%s\n", $2, $1 }' | numfmt --field=1 --to=iec --suffix=B | sed 's/^/  /'
  [ "$(wc -l <"$work_dir/tmp")" -gt 10 ] && printf '  ... %s entries in total\n' "$(wc -l <"$work_dir/tmp")"
  printf '  reclaimable: %s\n' "$(human "$total")"
  [ -s "$work_dir/tmp" ] && printf '  run: diskgc apply tmp\n'
  return 0
}

apply_tmp() {
  local entry
  report_tmp
  [ -s "$work_dir/tmp" ] || return 0
  confirm "Delete these $(wc -l <"$work_dir/tmp") entries?" || return 0
  while IFS=$'\t' read -r entry _; do
    rm -rf -- "$entry" || printf 'could not fully delete %s\n' "$entry" >&2
  done <"$work_dir/tmp"
}

have_docker() {
  command -v docker >/dev/null && docker info >/dev/null 2>&1
}

report_docker_cache() {
  section "docker-cache"
  have_docker || {
    printf '  Docker is not reachable\n'
    return 0
  }
  printf '  reclaimable: %s\n' "$(docker system df --format '{{json .}}' |
    jq -r 'select(.Type == "Build Cache") | .Reclaimable')"
  printf '  run: docker builder prune -af\n'
}

apply_docker_cache() {
  report_docker_cache
  have_docker || return 0
  confirm "Prune the whole build cache?" && docker builder prune -af
  return 0
}

report_docker_images() {
  section "docker-images"
  have_docker || {
    printf '  Docker is not reachable\n'
    return 0
  }
  printf '  untagged images: %s\n' "$(docker image ls -q -f dangling=true | wc -l)"
  printf '  unused anonymous volumes: %s\n' \
    "$(docker volume ls -q -f dangling=true -f label=com.docker.volume.anonymous | wc -l)"
  printf '  run: docker image prune -f && docker volume prune -f\n'
}

apply_docker_images() {
  report_docker_images
  have_docker || return 0
  confirm "Prune untagged images and unused anonymous volumes?" || return 0
  docker image prune -f
  docker volume prune -f
}

report_docker_volumes() {
  section "docker volumes over 1 GB (reported only)"
  have_docker || {
    printf '  Docker is not reachable\n'
    return 0
  }
  docker system df -v --format '{{json .Volumes}}' |
    jq -r '.[] | select(.Size | test("[GT]B$")) | "  \(.Size)\t\(.Name)  (\(.Links) container(s))"'
  printf '  delete one: docker compose stop <service>, docker rm <container>, docker volume rm <volume>\n'
}

go_cache_dir() {
  if command -v go >/dev/null; then
    go env GOCACHE
  else
    printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/go-build"
  fi
}

report_go_cache() {
  local dir
  dir="$(go_cache_dir)"
  section "go-cache"
  printf '  %s: %s\n' "$dir" "$(human "$(disk_bytes "$dir")")"
  printf '  run: go clean -cache\n'
}

apply_go_cache() {
  report_go_cache
  confirm "Clean the Go build cache?" || return 0
  if command -v go >/dev/null; then
    go clean -cache
  else
    rm -rf -- "$(go_cache_dir)"
  fi
}

report_pnpm() {
  local dir="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
  section "pnpm"
  printf '  %s: %s\n' "$dir" "$(human "$(disk_bytes "$dir")")"
  if command -v pnpm >/dev/null; then
    printf '  run: pnpm store prune\n'
  else
    printf '  run pnpm store prune in a shell that has pnpm\n'
  fi
}

apply_pnpm() {
  report_pnpm
  command -v pnpm >/dev/null || return 0
  confirm "Prune the pnpm store?" && pnpm store prune
  return 0
}

generations() {
  local count
  count="$(find "$(dirname "$1")" -maxdepth 1 -name "$(basename "$1")-*-link" | wc -l)"
  printf '%s' "$((count > NIXUP_RETAIN_GENERATIONS ? count - NIXUP_RETAIN_GENERATIONS : 0))"
}

report_nix() {
  local state_home="${XDG_STATE_HOME:-$HOME/.local/state}" dead
  section "nix"
  printf '  generations beyond the %s kept: home-manager %s, profile %s, system %s\n' \
    "$NIXUP_RETAIN_GENERATIONS" \
    "$(generations "$state_home/nix/profiles/home-manager")" \
    "$(generations "$state_home/nix/profiles/profile")" \
    "$(generations /nix/var/nix/profiles/system)"
  dead="$(nix-store --gc --print-dead 2>/dev/null | tr '\n' '\0' |
    { du -sc -B1 --files0-from=- 2>/dev/null || true; } | awk 'END { print $1 + 0 }')"
  printf '  unreferenced store paths now: up to %s (more after the generations go)\n' "$(human "$dead")"
  printf '  run: nixup clean\n'
}

apply_nix() {
  report_nix
  confirm "Run nixup clean?" && nixup clean
  return 0
}

report_large_dirs() {
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  section "large directories over ${DISKGC_LARGE_DIR_GIB} GB (reported only)"
  find "${XDG_CACHE_HOME:-$HOME/.cache}" "$data_home" -mindepth 1 -maxdepth 1 -type d \
    ! -name go-build ! -name docker ! -name pnpm -print0 2>/dev/null |
    xargs -0 -r du -s -B1 --one-file-system 2>/dev/null |
    awk -v min="$((DISKGC_LARGE_DIR_GIB * 1024 * 1024 * 1024))" '$1 >= min' |
    sort -nr | numfmt --field=1 --to=iec --suffix=B | sed 's/^/  /'
}

categories=(worktrees tmp docker-cache docker-images go-cache pnpm nix)

report() {
  printf 'Disk: %s\n' "$(df -h --output=used,avail,pcent / | tail -1 | awk '{ print $1 " used, " $2 " free (" $3 ")" }')"
  local category
  for category in "${categories[@]}"; do
    "report_${category//-/_}"
  done
  report_docker_volumes
  report_large_dirs
}

apply() {
  local category
  local -a selected=("$@")
  [ "${#selected[@]}" -gt 0 ] || die "apply needs a category or all"
  [ "${selected[*]}" = all ] && selected=("${categories[@]}")
  for category in "${selected[@]}"; do
    contains "$category" "${categories[@]}" || die "unknown category: $category"
  done
  for category in "${selected[@]}"; do
    "apply_${category//-/_}"
  done
  printf '\nDisk: %s\n' "$(df -h --output=avail / | tail -1) free"
}

case "${1:-report}" in
  report) report ;;
  apply)
    shift
    apply "$@"
    ;;
  -h | --help | help) usage ;;
  *)
    usage >&2
    exit 1
    ;;
esac
