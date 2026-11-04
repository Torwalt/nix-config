# Programs slot 2 of one or more YubiKeys with a shared HMAC-SHA1
# challenge-response secret, which is the form KeePassXC uses.
#
# The secret only lives in this process: it is shown once to be written down,
# never written to disk and never passed as a command-line argument. Each key
# is checked by asking it to answer a random challenge and comparing that
# with the HMAC computed here from the written-down secret.

SLOT=2

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

clear_screen() {
  # Also wipes the scrollback, so the secret is not left on screen.
  printf '\033[2J\033[3J\033[H'
}

normalize_secret() {
  tr -d ' \t-' <<<"$1" | tr '[:upper:]' '[:lower:]'
}

# Waits until exactly one YubiKey is connected, sets `serial` to its serial
# number. `previous` is a serial that must not be accepted again.
wait_for_single_key() {
  local previous=${1:-}
  local -a serials
  while true; do
    mapfile -t serials < <(ykman list --serials 2>/dev/null)
    if ((${#serials[@]} == 1)) && [[ ${serials[0]} != "$previous" ]]; then
      serial=${serials[0]}
      return
    fi
    if ((${#serials[@]} == 0)); then
      pause "No YubiKey found. Plug in the key to program."
    elif ((${#serials[@]} > 1)); then
      pause "${#serials[@]} YubiKeys are connected. Leave only the key to program plugged in."
    else
      pause "Key $previous is already done. Unplug it and plug in the next key."
    fi
  done
}

check_key() {
  echo
  ykman --device "$serial" info
  echo

  ykman --device "$serial" otp info >/dev/null 2>&1 ||
    die "key $serial has no OTP application (Security Key models only do FIDO2) or it is disabled; see 'ykman config usb --help'"

  if ! ykman --device "$serial" otp info | grep -q "Slot $SLOT: empty"; then
    echo "Slot $SLOT of key $serial is already programmed."
    echo "Overwriting it locks you out of every database that uses the old secret."
    local reply
    read -r -p "Type 'overwrite' to continue: " reply
    [[ $reply == overwrite ]] || die "left slot $SLOT untouched"
  fi
}

new_secret() {
  secret=$(od -An -N20 -tx1 /dev/urandom | tr -d ' \n')

  clear_screen
  cat <<EOF
This is your new challenge-response secret. Write it down on paper now and
keep the paper somewhere safe at home, not next to the key.

    $(fold -w4 <<<"$secret" | paste -sd' ')

Anyone who holds this secret can act as your YubiKey. With it you can
program a replacement key if this one is lost or breaks.

EOF
  pause "Once you have written it down, the screen gets cleared."

  local typed attempt
  for attempt in 1 2 3; do
    clear_screen
    read -r -s -p "Type the secret back from your paper (spaces are fine): " typed
    echo
    if [[ $(normalize_secret "$typed") == "$secret" ]]; then
      echo "The paper copy matches."
      return
    fi
    echo "That does not match (attempt $attempt of 3)."
  done
  die "the paper copy could not be confirmed; nothing was programmed, start again"
}

existing_secret() {
  local typed
  read -r -s -p "Enter the secret from your paper (spaces are fine): " typed
  echo
  secret=$(normalize_secret "$typed")
  [[ $secret =~ ^[0-9a-f]{40}$ ]] || die "expected 40 hex characters, got ${#secret}"
}

program_key() {
  echo "Programming slot $SLOT of key $serial (touch required to answer)..."
  # The secret goes through stdin; ykman then asks for confirmation.
  printf '%s\ny\n' "$secret" |
    ykman --device "$serial" otp chalresp --touch "$SLOT" >/dev/null
}

verify_key() {
  local challenge expected response
  challenge=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
  expected=$(
    printf '%s\n%s\n' "$secret" "$challenge" | python3 -I -c '
import hashlib, hmac, sys
key = bytes.fromhex(sys.stdin.readline().strip())
challenge = bytes.fromhex(sys.stdin.readline().strip())
print(hmac.new(key, challenge, hashlib.sha1).hexdigest())
'
  )

  echo "Checking key $serial: touch it when it blinks."
  response=$(ykman --device "$serial" otp calculate "$SLOT" "$challenge")

  [[ $response == "$expected" ]] ||
    die "key $serial answered differently from the written-down secret; do not use it for a database"
  echo "Key $serial answers with the written-down secret."
}

[[ -t 0 ]] || die "run this in a terminal"

cat <<EOF
YubiKey setup for KeePassXC challenge-response (slot $SLOT)

  1) First key: generate a new secret
  2) Backup or replacement key: use the secret from your paper

EOF
read -r -p "Choice [1/2]: " mode

serial=
secret=
trap 'secret=' EXIT

wait_for_single_key
check_key

case $mode in
  1) new_secret ;;
  2) existing_secret ;;
  *) die "unknown choice: $mode" ;;
esac

programmed=()
while true; do
  program_key
  verify_key
  programmed+=("$serial")

  echo
  if ask "Set or change the FIDO2 PIN of key $serial (used later for SSH keys and passkeys)?"; then
    ykman --device "$serial" fido access change-pin
  fi

  echo
  ask "Program another key (your backup) with the same secret now?" || break
  wait_for_single_key "$serial"
  check_key
done

secret=

echo
echo "Done. Keys sharing the secret: ${programmed[*]}"
if ((${#programmed[@]} < 2)); then
  echo "Only one key holds the secret. Program a backup later with: yubikey-setup (choice 2)"
fi
echo "Next: kdbx-yubikey --dry-run <database.kdbx>"
