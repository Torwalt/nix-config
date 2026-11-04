# Adds YubiKey challenge-response to a KeePassXC database, trying it on a copy
# first.
#
# The copy lives in $XDG_RUNTIME_DIR (RAM, outside any synced folder). The
# YubiKey is added to it in the KeePassXC GUI, since keepassxc-cli cannot add
# one. The script then checks the copy: the password alone must fail, the
# password plus each tested key must open it, and it must list the same
# entries as the original. Only then, and only without --dry-run, does it
# back up the original and put the copy in its place.

SLOT=2

usage() {
  cat <<EOF
Usage: kdbx-yubikey [--dry-run] DATABASE.kdbx

Adds YubiKey challenge-response (slot $SLOT) to DATABASE, trying it on a copy
first. With --dry-run the original is never touched.
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

ask() {
  local reply
  read -r -p "$1 [y/N] " reply
  [[ $reply == [yY]* ]]
}

pause() {
  read -r -p "$1 Press Enter to continue. " _
}

dry_run=false
db=
while (($#)); do
  case $1 in
    --dry-run | -n) dry_run=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*) die "unknown option: $1" ;;
    *)
      [[ -z $db ]] || die "only one database at a time"
      db=$1
      ;;
  esac
  shift
done

[[ -n $db ]] || {
  usage >&2
  exit 2
}
[[ -t 0 ]] || die "run this in a terminal"
[[ -f $db ]] || die "no such file: $db"
db=$(realpath "$db")

password=
trap 'password=' EXIT

# Runs keepassxc-cli with the password on stdin. Extra arguments come before
# the database path.
kpcli() {
  local command=$1 file=$2
  shift 2
  printf '%s\n' "$password" | keepassxc-cli "$command" -q "$@" "$file"
}

# Lists entry paths of a database, which is enough to see nothing got lost
# without exporting any secrets.
list_entries() {
  local file=$1
  shift
  printf '%s\n' "$password" | keepassxc-cli ls -q -R -f "$@" "$file" | sort
}

connected_serials() {
  ykman list --serials 2>/dev/null
}

read -r -s -p "Master password of $(basename "$db"): " password
echo
kpcli db-info "$db" >/dev/null ||
  die "could not open $db with that password alone (wrong password, or it already uses a key file or YubiKey)"

entries_before=$(list_entries "$db")

workdir=$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/kdbx-yubikey.XXXXXX")
trap 'password=; rm -rf "$workdir"' EXIT
copy="$workdir/$(basename "$db")"
cp "$db" "$copy"
original_hash=$(sha256sum <"$db")
copy_hash=$original_hash

cat <<EOF

The copy to practise on is:

    $copy

KeePassXC opens it now. In KeePassXC:

  1. Check that the tab shows the copy above, not your real database.
  2. Database > Database Security > Add additional protection
  3. Add YubiKey Challenge-Response, pick slot $SLOT of your key, touch it.
  4. Keep the password as it is. Click OK, save (Ctrl+S), close the tab.

EOF
setsid keepassxc "$copy" >/dev/null 2>&1 &

while true; do
  pause "When the copy is saved and closed in KeePassXC,"
  copy_hash=$(sha256sum <"$copy")
  [[ $copy_hash != "$original_hash" ]] && break
  echo "The copy is unchanged. Save it in KeePassXC (Ctrl+S) first."
done

echo
echo "Check 1: the password alone must no longer open the copy."
if kpcli db-info "$copy" >/dev/null 2>&1; then
  die "the copy still opens with the password alone; the YubiKey was not added"
fi
echo "  ok: the password alone is rejected."

tested=()
test_key() {
  local serial=$1 entries_after
  echo
  echo "Check 2: password + key $serial must open the copy. Touch the key when it blinks."
  entries_after=$(list_entries "$copy" -y "$SLOT:$serial") ||
    die "key $serial could not open the copy"
  echo "  ok: key $serial opens it."

  echo "Check 3: the copy must list the same entries as the original."
  if ! diff <(printf '%s\n' "$entries_before") <(printf '%s\n' "$entries_after") >/dev/null; then
    diff <(printf '%s\n' "$entries_before") <(printf '%s\n' "$entries_after") || true
    die "the copy lists different entries than the original"
  fi
  echo "  ok: $(grep -cv '/$' <<<"$entries_after" || true) entries, same as the original."
  tested+=("$serial")
}

while true; do
  mapfile -t serials < <(connected_serials)
  untested=()
  for serial in "${serials[@]}"; do
    [[ " ${tested[*]} " == *" $serial "* ]] || untested+=("$serial")
  done

  if ((${#untested[@]} == 0)); then
    if ((${#tested[@]} == 0)); then
      pause "No YubiKey connected. Plug one in."
      continue
    fi
    echo
    ask "Test another key (your backup)? Plug it in first." || break
    continue
  fi

  for serial in "${untested[@]}"; do
    test_key "$serial"
  done
done

echo
echo "Keys that open the copy: ${tested[*]}"
if ((${#tested[@]} < 2)); then
  echo "WARNING: only one key was tested. If it breaks, only the paper secret"
  echo "(yubikey-setup, choice 2) gets you back in."
fi

if $dry_run; then
  echo
  echo "Dry run: the copy works. $db was not touched; the copy gets deleted now."
  echo "Run without --dry-run to apply it."
  exit 0
fi

echo
ask "Replace $db with the tested copy?" || {
  echo "Left $db untouched."
  exit 0
}
pause "Lock or close $(basename "$db") in KeePassXC first, so it does not save over the new file."

[[ $(sha256sum <"$db") == "$original_hash" ]] ||
  die "$db changed since it was copied (KeePassXC or Dropbox wrote to it); start again"

backup_dir=${XDG_DATA_HOME:-$HOME/.local/share}/kdbx-yubikey
mkdir -p "$backup_dir"
chmod 700 "$backup_dir"
backup="$backup_dir/$(basename "$db" .kdbx).$(date +%Y%m%d-%H%M%S).password-only.kdbx"
cp -p "$db" "$backup"

# Copy next to the target first, so the rename that replaces it is atomic.
staged="$db.kdbx-yubikey-tmp"
cp "$copy" "$staged"
mv -f "$staged" "$db"

[[ $(sha256sum <"$db") == "$copy_hash" ]] || die "$db does not match the tested copy; the original is at $backup"

cat <<EOF

Done. $db now needs the password and a YubiKey.

The old password-only version is backed up outside Dropbox at:

    $backup

It still opens with the password alone. Delete it once you have used the new
database for a while:

    rm "$backup"
EOF
