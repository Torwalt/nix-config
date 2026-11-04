# Copies KeePassXC databases to a thumb drive as dated backups.
#
# Each backup is checked against its source by checksum and, if you want, by
# opening it from the drive with your password (plus a YubiKey when one is
# connected).
#
# With --password-only, each database that needs a YubiKey also gets a second
# backup that opens with the password alone, as a fallback for when every key
# and the paper secret are gone. keepassxc-cli cannot remove a YubiKey from a
# database, so that copy is rebuilt: exported to XML and imported into a new
# database with the same password. The XML holds every secret in plain text,
# so it only ever exists in $XDG_RUNTIME_DIR (RAM) and is deleted right after.
# The rebuilt database is exported again and must match the original export. Drives this script mounted itself are unmounted and powered off
# at the end, so they can be pulled out right away.

SLOT=2

usage() {
  cat <<EOF
Usage: kdbx-backup [--to DIR] [--keep N] [--password-only] DATABASE.kdbx...

Copies each DATABASE to DIR/kdbx-backup/NAME.YYYYMMDD-HHMMSS.kdbx on a thumb
drive. Without --to, it picks a plugged-in USB drive and mounts it if needed.

  --to DIR         back up into DIR instead of looking for a drive
  --keep N         keep only the newest N backups of each kind per database
  --password-only  also write NAME.YYYYMMDD-HHMMSS.password-only.kdbx, which
                   opens with the master password alone, no YubiKey
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

target_dir=
keep=
password_only=false
dbs=()
while (($#)); do
  case $1 in
    --to)
      (($# >= 2)) || die "--to needs a directory"
      target_dir=$2
      shift
      ;;
    --keep)
      (($# >= 2)) || die "--keep needs a number"
      [[ $2 =~ ^[1-9][0-9]*$ ]] || die "--keep needs a positive number, got: $2"
      keep=$2
      shift
      ;;
    --password-only) password_only=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*) die "unknown option: $1" ;;
    *) dbs+=("$1") ;;
  esac
  shift
done

((${#dbs[@]})) || {
  usage >&2
  exit 2
}
[[ -t 0 ]] || die "run this in a terminal"
for i in "${!dbs[@]}"; do
  [[ -f ${dbs[$i]} ]] || die "no such file: ${dbs[$i]}"
  dbs[i]=$(realpath "${dbs[$i]}")
done

# Prints "path<TAB>label<TAB>size<TAB>fstype<TAB>mountpoint<TAB>disk" for
# every filesystem on a removable or hot-plugged drive.
removable_filesystems() {
  lsblk -J -l -p -o PATH,PKNAME,TYPE,RM,HOTPLUG,LABEL,SIZE,FSTYPE,MOUNTPOINT |
    jq -r '
      .blockdevices[]
      | select((.rm or .hotplug) and .fstype != null
               and .fstype != "swap" and .fstype != "crypto_LUKS")
      | [.path, (.label // "-"), .size, .fstype, (.mountpoint // ""),
         (.pkname // .path)]
      | @tsv
    '
}

mounted_by_us=
disk=
pick_drive() {
  local -a drives
  local line choice
  while true; do
    mapfile -t drives < <(removable_filesystems)
    ((${#drives[@]})) && break
    pause "No thumb drive found. Plug one in."
  done

  if ((${#drives[@]} == 1)); then
    line=${drives[0]}
  else
    echo "Several drives are connected:"
    for i in "${!drives[@]}"; do
      IFS=$'\t' read -r path label size fstype mountpoint _ <<<"${drives[$i]}"
      printf '  %d) %s  %s  %s  %s  %s\n' $((i + 1)) "$path" "$label" "$size" "$fstype" "${mountpoint:-(not mounted)}"
    done
    read -r -p "Back up to [1-${#drives[@]}]: " choice
    if ! [[ $choice =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#drives[@]})); then
      die "no such drive: $choice"
    fi
    line=${drives[$((choice - 1))]}
  fi

  IFS=$'\t' read -r path label size fstype mountpoint disk <<<"$line"
  echo "Drive: $path ($label, $size, $fstype)"

  if [[ -z $mountpoint ]]; then
    udisksctl mount -b "$path" >/dev/null
    mounted_by_us=$path
    mountpoint=$(lsblk -n -o MOUNTPOINT "$path")
    [[ -n $mountpoint ]] || die "could not mount $path"
    echo "Mounted at $mountpoint"
  fi
  target_dir=$mountpoint
}

finish_drive() {
  sync
  [[ -n $mounted_by_us ]] || {
    echo "Leaving $target_dir mounted, as it was before."
    return
  }
  udisksctl unmount -b "$mounted_by_us" >/dev/null
  udisksctl power-off -b "$disk" >/dev/null 2>&1 || true
  echo "Unmounted $mounted_by_us. You can pull the drive out."
}

password=
workdir=
trap 'password=; [[ -z $workdir ]] || rm -rf "$workdir"' EXIT

if $password_only; then
  # Plain-text exports must never touch a disk; /tmp is not RAM on NixOS.
  [[ -n ${XDG_RUNTIME_DIR:-} && -d $XDG_RUNTIME_DIR ]] ||
    die "--password-only needs \$XDG_RUNTIME_DIR (RAM) for the plain-text export"
  workdir=$(umask 077 && mktemp -d "$XDG_RUNTIME_DIR/kdbx-backup.XXXXXX")
fi

# Exports FILE as XML to OUT, trying a connected YubiKey first and then the
# password alone. Sets `used_key` to the serial that opened it, or empty.
used_key=
export_db() {
  local file=$1 out=$2 serial
  serial=$(ykman list --serials 2>/dev/null | head -n1 || true)
  if [[ -n $serial ]]; then
    echo "  Touch YubiKey $serial if it blinks."
    if printf '%s\n' "$password" |
      keepassxc-cli export -q -y "$SLOT:$serial" "$file" >"$out" 2>/dev/null; then
      used_key=$serial
      return
    fi
  fi
  used_key=
  printf '%s\n' "$password" | keepassxc-cli export -q "$file" >"$out" 2>/dev/null
}

# Compares two XML exports, ignoring the random padding KeePassXC adds to
# every database. Prints the number of entries when they match. Never prints
# any content, since the exports hold every secret.
same_export() {
  python3 -I - "$1" "$2" <<'EOF'
import sys
import xml.etree.ElementTree as ET

def load(path):
    root = ET.parse(path).getroot()
    for custom in root.iter("CustomData"):
        for item in list(custom.findall("Item")):
            if item.findtext("Key") == "KPXC_RANDOM_SLUG":
                custom.remove(item)
    # Indentation is not content, and removing the padding shifts it.
    for element in root.iter():
        if element.text is not None and not element.text.strip():
            element.text = None
        if element.tail is not None and not element.tail.strip():
            element.tail = None
    return root

a, b = load(sys.argv[1]), load(sys.argv[2])
if ET.tostring(a) != ET.tostring(b):
    sys.exit(1)
print(sum(len(group.findall("Entry")) for group in a.iter("Group")))
EOF
}

# Copies SRC to DEST under a temporary name first, so a pulled drive never
# leaves a half-written file that looks like a backup. Fails if the copy on
# the drive differs.
copy_to_drive() {
  local src=$1 dest=$2
  cp "$src" "$dest.tmp"
  sync -f "$dest.tmp"
  mv -f "$dest.tmp" "$dest"
  [[ $(sha256sum <"$src") == "$(sha256sum <"$dest")" ]]
}

# Rebuilds the database exported to XML as a password-only database at DEST
# and checks that it holds exactly what the export holds.
write_password_only() {
  local xml=$1 dest=$2 rebuilt="$workdir/rebuilt.kdbx" entries
  rm -f "$rebuilt"
  printf '%s\n%s\n' "$password" "$password" |
    keepassxc-cli import -q -p "$xml" "$rebuilt" >/dev/null 2>&1 ||
    return 1
  printf '%s\n' "$password" | keepassxc-cli export -q "$rebuilt" >"$workdir/rebuilt.xml" 2>/dev/null ||
    return 1
  entries=$(same_export "$xml" "$workdir/rebuilt.xml") || return 1
  copy_to_drive "$rebuilt" "$dest" || return 1
  rm -f "$workdir/rebuilt.xml" "$rebuilt"
  echo "  ok: password-only copy at $dest ($entries entries, matches the original)."
}

prune() {
  local dir=$1 pattern=$2
  local -a old
  [[ -n $keep ]] || return 0
  mapfile -t old < <(find "$dir" -maxdepth 1 -name "$pattern" -printf '%f\n' | sort -r | tail -n +"$((keep + 1))")
  for f in "${old[@]}"; do
    rm -f -- "${dir:?}/$f"
    echo "  removed old backup $f"
  done
}

if [[ -n $target_dir ]]; then
  [[ -d $target_dir ]] || die "no such directory: $target_dir"
else
  pick_drive
fi

backup_dir="$target_dir/kdbx-backup"
mkdir -p "$backup_dir"
stamp=$(date +%Y%m%d-%H%M%S)

verify=$password_only
if ! $verify && ask "Check that each backup opens from the drive (asks for the master password)?"; then
  verify=true
fi

failed=0
for db in "${dbs[@]}"; do
  stem=$(basename "$db" .kdbx)
  target="$backup_dir/$stem.$stamp.kdbx"
  echo
  echo "$db"

  if ! copy_to_drive "$db" "$target"; then
    echo "  FAILED: the copy on the drive differs from the source."
    failed=1
    continue
  fi
  echo "  copied to $target"

  if $verify; then
    read -r -s -p "  Master password of $stem: " password
    echo
    xml=/dev/null
    [[ -z $workdir ]] || xml="$workdir/export.xml"

    # Opening the drive copy checks the backup and, for --password-only,
    # produces the export to rebuild from.
    opened=true
    if ! export_db "$target" "$xml"; then
      opened=false
      echo "  FAILED: the backup did not open with that password (and connected YubiKey)."
      failed=1
    elif [[ -n $used_key ]]; then
      echo "  ok: opens with the password and YubiKey $used_key."
    else
      echo "  ok: opens with the password alone."
    fi

    if $password_only && $opened; then
      if [[ -z $used_key ]]; then
        echo "  skipped password-only copy: this database needs no YubiKey anyway."
      elif ! write_password_only "$xml" "$backup_dir/$stem.$stamp.password-only.kdbx"; then
        echo "  FAILED: could not write a matching password-only copy."
        failed=1
      fi
    fi
    [[ $xml == /dev/null ]] || rm -f "$xml"
    password=
  fi

  prune "$backup_dir" "$stem.????????-??????.kdbx"
  prune "$backup_dir" "$stem.????????-??????.password-only.kdbx"
done

echo
echo "Backups on the drive:"
ls -1 "$backup_dir"
echo

if [[ -n $disk ]]; then
  finish_drive
else
  sync
fi

if ((failed)); then
  die "some backups failed, see above"
fi

cat <<EOF

To restore you need the backup, the master password, and a YubiKey or the
paper secret (yubikey-setup, choice 2). A .password-only.kdbx backup needs
just the master password. Keep the drive somewhere other than the paper
secret.
EOF
