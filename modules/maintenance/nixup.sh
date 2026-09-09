usage() {
  cat <<'EOF'
Usage: nixup [COMMAND]

Commands:
  update  Update flake.lock, validate, deploy, and clean (default)
  apply   Validate and deploy the current flake.lock, then clean
  check   Validate and build both configurations without activating
  clean   Keep the configured number of generations and collect garbage
          Pass --dry-run to preview generation removal
  status  Show deployment age, generations, disk use, and reboot state
EOF
}

die() {
  printf 'nixup: %s\n' "$*" >&2
  exit 1
}

state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
state_dir="$state_home/nixup"
success_file="$state_dir/last-success"
reminder_file="$state_dir/last-reminder"
home_profile="$state_home/nix/profiles/home-manager"
user_profile="$state_home/nix/profiles/profile"
system_profile="/nix/var/nix/profiles/system"
repo="${NIX_CONFIG_REPO:-$NIXUP_DEFAULT_REPO}"
sudo_command="/run/wrappers/bin/sudo"

section() {
  printf '\n==> %s\n' "$*"
}

run_as_root() {
  [ -x "$sudo_command" ] || die "NixOS sudo wrapper not found at $sudo_command"
  "$sudo_command" "$@"
}

prepare_repo() {
  [ -f "$repo/flake.nix" ] || die "no flake.nix found at $repo (override with NIX_CONFIG_REPO)"
  [ -d "$repo/.git" ] || die "$repo is not a Git working tree"
  cd "$repo"
}

acquire_lock() {
  mkdir -p "$state_dir"
  exec 9>"$state_dir/run.lock"
  flock --nonblock 9 || die "another nixup process is already running"
}

show_worktree() {
  local worktree_status
  worktree_status="$(git status --short)"
  if [ -n "$worktree_status" ]; then
    printf 'The working tree has local changes. Tracked changes are included; untracked files are ignored by Git flakes:\n%s\n' "$worktree_status"
  fi
}

update_lock() {
  if ! git diff --quiet -- flake.lock || ! git diff --cached --quiet -- flake.lock; then
    die "flake.lock already has uncommitted changes; use 'nixup apply' or commit them first"
  fi

  section "Updating flake inputs"
  nix flake update
}

build_configurations() {
  section "Running flake checks"
  nix flake check --show-trace

  section "Building NixOS configuration $NIXUP_SYSTEM_CONFIGURATION"
  new_system="$(
    nix build \
      --no-link \
      --print-out-paths \
      ".#nixosConfigurations.$NIXUP_SYSTEM_CONFIGURATION.config.system.build.toplevel"
  )"

  section "Building Home Manager configuration $NIXUP_HOME_CONFIGURATION"
  new_home="$(
    nix build \
      --no-link \
      --print-out-paths \
      ".#homeConfigurations.$NIXUP_HOME_CONFIGURATION.activationPackage"
  )"

  section "NixOS changes"
  nix store diff-closures /run/current-system "$new_system" || true

  if [ -e "$home_profile" ]; then
    section "Home Manager changes"
    nix store diff-closures "$(readlink -f "$home_profile")" "$new_home" || true
  fi
}

record_success() {
  local stamp_tmp revision lock_hash system_generation home_generation
  revision="$(git rev-parse HEAD)"
  lock_hash="$(sha256sum flake.lock | cut -d ' ' -f 1)"
  system_generation="$(readlink "$system_profile")"
  home_generation="$(readlink "$home_profile")"
  stamp_tmp="$(mktemp "$state_dir/.last-success.XXXXXX")"

  {
    printf 'timestamp=%s\n' "$(date +%s)"
    printf 'host=%s\n' "$NIXUP_SYSTEM_CONFIGURATION"
    printf 'revision=%s\n' "$revision"
    printf 'lock_hash=%s\n' "$lock_hash"
    printf 'system_generation=%s\n' "$system_generation"
    printf 'home_generation=%s\n' "$home_generation"
  } > "$stamp_tmp"

  mv "$stamp_tmp" "$success_file"
}

clean_generations() {
  local mode dry_run_args
  mode="${1:-}"
  dry_run_args=()

  case "$mode" in
    "") ;;
    --dry-run) dry_run_args=(--dry-run) ;;
    *) die "unknown clean option: $mode" ;;
  esac

  section "Disk usage before cleanup"
  df -h /nix/store

  if [ -e "$home_profile" ]; then
    section "Keeping the latest $NIXUP_RETAIN_GENERATIONS Home Manager generations"
    nix-env \
      --profile "$home_profile" \
      --delete-generations "+$NIXUP_RETAIN_GENERATIONS" \
      "${dry_run_args[@]}"
  fi

  if [ -e "$user_profile" ]; then
    section "Keeping the latest $NIXUP_RETAIN_GENERATIONS user profile generations"
    nix-env \
      --profile "$user_profile" \
      --delete-generations "+$NIXUP_RETAIN_GENERATIONS" \
      "${dry_run_args[@]}"
  fi

  section "Keeping the latest $NIXUP_RETAIN_GENERATIONS NixOS generations"
  run_as_root nix-env \
    --profile "$system_profile" \
    --delete-generations "+$NIXUP_RETAIN_GENERATIONS" \
    "${dry_run_args[@]}"

  if [ "$mode" = "--dry-run" ]; then
    printf '\nDry run complete; garbage collection was not run.\n'
    return 0
  fi

  section "Collecting unreferenced store paths"
  run_as_root nix store gc

  section "Disk usage after cleanup"
  df -h /nix/store
}

deploy() {
  section "Activating NixOS configuration"
  run_as_root --validate
  run_as_root nixos-rebuild switch --flake ".#$NIXUP_SYSTEM_CONFIGURATION"

  section "Activating Home Manager configuration"
  home-manager switch --flake ".#$NIXUP_HOME_CONFIGURATION"

  record_success
  section "Deployment recorded successfully"

  if [ "${NIXUP_SKIP_CLEANUP:-0}" = "1" ]; then
    printf 'Skipping cleanup because NIXUP_SKIP_CLEANUP=1.\n'
  else
    clean_generations
  fi
}

field() {
  sed -n "s/^$1=//p" "$success_file" | head -n 1
}

generation_count() {
  local directory pattern
  directory="$1"
  pattern="$2"

  if [ -d "$directory" ]; then
    find "$directory" -maxdepth 1 -type l -name "$pattern" -print | wc -l
  else
    printf '0\n'
  fi
}

show_status() {
  local timestamp now age_days deployed_lock_hash current_lock_hash

  printf 'Host: %s / %s\n' "$NIXUP_SYSTEM_CONFIGURATION" "$NIXUP_HOME_CONFIGURATION"
  printf 'Repository: %s\n' "$repo"

  if [ -f "$success_file" ]; then
    timestamp="$(field timestamp)"
    if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
      now="$(date +%s)"
      age_days="$(( (now - timestamp) / 86400 ))"
      printf 'Last successful deployment: %s (%s days ago)\n' \
        "$(date --date="@$timestamp" --iso-8601=seconds)" \
        "$age_days"
      printf 'Git revision: %s\n' "$(field revision)"
      printf 'System generation: %s\n' "$(field system_generation)"
      printf 'Home generation: %s\n' "$(field home_generation)"

      deployed_lock_hash="$(field lock_hash)"
      current_lock_hash="$(sha256sum "$repo/flake.lock" | cut -d ' ' -f 1)"
      if [ "$deployed_lock_hash" = "$current_lock_hash" ]; then
        printf 'Current flake.lock deployed: yes\n'
      else
        printf 'Current flake.lock deployed: no\n'
      fi
    else
      printf 'Last successful deployment: invalid status file\n'
    fi
  else
    printf 'Last successful deployment: not yet recorded\n'
  fi

  printf 'NixOS generations: %s\n' \
    "$(generation_count /nix/var/nix/profiles 'system-*-link')"
  printf 'Home Manager generations: %s\n' \
    "$(generation_count "$(dirname "$home_profile")" 'home-manager-*-link')"
  printf 'User profile generations: %s\n' \
    "$(generation_count "$(dirname "$user_profile")" 'profile-*-link')"

  if [ -e /run/booted-system/kernel ] \
    && [ "$(readlink -f /run/booted-system/kernel)" != "$(readlink -f /run/current-system/kernel)" ]; then
    printf 'Reboot recommended: yes (the configured kernel is not booted)\n'
  else
    printf 'Reboot recommended: no\n'
  fi

  printf '\n'
  df -h /nix/store
}

remind() {
  local timestamp now age_days today last_reminder message
  message=""

  if [ -f "$success_file" ]; then
    timestamp="$(field timestamp)"
    if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
      now="$(date +%s)"
      age_days="$(( (now - timestamp) / 86400 ))"
      if [ "$age_days" -ge "$NIXUP_REMINDER_DAYS" ]; then
        message="Your last successful nixup was $age_days days ago. Run 'nixup' when convenient."
      fi
    fi
  else
    message="nixup has not recorded a successful deployment yet. Run 'nixup' when convenient."
  fi

  [ -n "$message" ] || return 0

  mkdir -p "$state_dir"
  today="$(date +%F)"
  last_reminder=""
  if [ -f "$reminder_file" ]; then
    last_reminder="$(head -n 1 "$reminder_file")"
  fi

  if [ "$last_reminder" != "$today" ]; then
    printf '\033[33m%s\033[0m\n' "$message" >&2
    printf '%s\n' "$today" > "$reminder_file"
  fi
}

command="${1:-update}"

case "$command" in
  update)
    acquire_lock
    prepare_repo
    show_worktree
    update_lock
    build_configurations
    deploy
    ;;
  apply)
    acquire_lock
    prepare_repo
    show_worktree
    build_configurations
    deploy
    ;;
  check)
    acquire_lock
    prepare_repo
    show_worktree
    build_configurations
    ;;
  clean)
    acquire_lock
    clean_generations "${2:-}"
    ;;
  status)
    prepare_repo
    show_status
    ;;
  remind)
    remind
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    die "unknown command: $command"
    ;;
esac
