# Copies KeePassXC databases to a thumb drive as dated backups.
#
# Each backup is checked against its source by checksum and, if you want, by
# opening it from the drive with your password (plus a YubiKey when one is
# connected). Drives this script mounted itself are unmounted and powered off
# at the end, so they can be pulled out right away.

SLOT=2

usage() {
  cat <<EOF
Usage: kdbx-backup [--to DIR] [--keep N] DATABASE.kdbx...

Copies each DATABASE to DIR/kdbx-backup/NAME.YYYYMMDD-HHMMSS.kdbx on a thumb
drive. Without --to, it picks a plugged-in USB drive and mounts it if needed.

  --to DIR   back up into DIR instead of looking for a drive
  --keep N   keep only the newest N backups of each database on the drive
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
trap 'password=' EXIT

# Opens a backup with the password, using a connected YubiKey when there is
# one. Prints how it opened.
check_opens() {
  local file=$1 serial
  serial=$(ykman list --serials 2>/dev/null | head -n1 || true)
  if [[ -n $serial ]]; then
    echo "  Touch YubiKey $serial if it blinks."
    if printf '%s\n' "$password" | keepassxc-cli db-info -q -y "$SLOT:$serial" "$file" >/dev/null 2>&1; then
      echo "  ok: opens with the password and YubiKey $serial."
      return
    fi
  fi
  if printf '%s\n' "$password" | keepassxc-cli db-info -q "$file" >/dev/null 2>&1; then
    echo "  ok: opens with the password alone."
    return
  fi
  return 1
}

prune() {
  local dir=$1 stem=$2
  local -a old
  [[ -n $keep ]] || return 0
  mapfile -t old < <(find "$dir" -maxdepth 1 -name "$stem.*.kdbx" -printf '%f\n' | sort -r | tail -n +"$((keep + 1))")
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

verify=false
if ask "Check that each backup opens from the drive (asks for the master password)?"; then
  verify=true
fi

failed=0
for db in "${dbs[@]}"; do
  stem=$(basename "$db" .kdbx)
  target="$backup_dir/$stem.$stamp.kdbx"
  echo
  echo "$db"

  # Copy under a temporary name first, so a pulled drive never leaves a
  # half-written file that looks like a backup.
  cp "$db" "$target.tmp"
  sync -f "$target.tmp"
  mv -f "$target.tmp" "$target"

  if [[ $(sha256sum <"$db") != "$(sha256sum <"$target")" ]]; then
    echo "  FAILED: the copy on the drive differs from the source."
    failed=1
    continue
  fi
  echo "  copied to $target"

  if $verify; then
    read -r -s -p "  Master password of $stem: " password
    echo
    if ! check_opens "$target"; then
      echo "  FAILED: the backup did not open with that password (and connected YubiKey)."
      failed=1
    fi
    password=
  fi

  prune "$backup_dir" "$stem"
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
paper secret (yubikey-setup, choice 2). Keep the drive somewhere other than
the paper secret.
EOF
