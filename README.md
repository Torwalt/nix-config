# My NixOS config

## First time setting up

- dont forget to copy generated hardware-configuration.nix and include it in configuration.nix
- if full disk encryption was chosen in installer, dont forget to add that part into configuration.nix

## Host kinds

`modules/system/core.nix` holds what every host needs: locale, German keymap,
NetworkManager, PipeWire, firewall, Nix settings. Two profiles import it.

`workstation.nix` is the profile for hosts administered by their user: the
`ada` account with sudo, Docker, Zsh, Kitty, the fcitx5 translit setup.
`asus`, `tower` and `work` use it.

`managed.nix` is the profile for a host whose user does not administer it. The
day-to-day account has no sudo, a second account keeps it, and the host pulls
its own upgrades from a flake reference on a timer. `socke` uses it.

## Installing socke

`hosts/iso/README.md` has the procedure: Windows preparation, partitioning
next to it, and the install from the live image.

`socke` then upgrades itself daily from the `socke-stable` branch with
`nixos-rebuild boot`, so a change lands on her next power-on and never
restarts anything under a running session. Release by advancing that branch:

```console
just release-socke
```

`socke-stable` only ever holds commits that are already on `master`, so it
fast-forwards and never needs a rebase. Keeping it behind `master` is the
point: a broken `master` does not reach an unattended machine. Failed builds
change nothing, and older generations stay in the boot menu for 30 days.

## Tasks

`just` is in the dev shell, so direnv puts it on the path in this directory.
It holds repository-level tasks; per-host updates stay in `nixup`.

```console
just              # list recipes
just fmt
just check        # evaluate every host, run the pre-commit hooks
just build towerSys
just iso          # build the socke installer image
just iso-write /dev/sdb
just release-socke
```

## Updating and cleanup

Every host installs a `nixup` command through Home Manager. It knows the
matching NixOS and Home Manager flake outputs for that host.

```console
nixup          # update inputs, check, build, deploy, and clean
nixup apply    # deploy the existing lock file without updating it
nixup check    # check and build without activating anything
nixup clean    # retain four generations and garbage-collect
nixup clean --dry-run # preview which generations would be removed
nixup status   # show update age, generation counts, disk use, and reboot state
```

`nixup` builds both configurations before activating either one. It switches
NixOS first and Home Manager second, and records an update as successful only
after both activations complete. Cleanup retains the latest four NixOS, Home
Manager, and user-profile generations before collecting unreferenced store
paths. Set `NIXUP_SKIP_CLEANUP=1` to skip cleanup for a particular deployment.

The existing `homeswitch` and `sysswitch` aliases remain available for
independent changes and now work from any directory. On a fresh checkout,
bootstrap `nixup` once from the repository with, for example,
`home-manager switch --flake .#workHome` (using the current host's output).

The success record is local to each machine under
`~/.local/state/nixup/last-success`. Interactive Zsh sessions show a reminder
once per day when the last successful deployment is at least 14 days old.

The default update command refuses to update an already-modified `flake.lock`.
Use `nixup apply` to deploy that lock file, or commit it first. After updating
on one host, review and commit `flake.lock`, then pull the commit and use
`nixup apply` on the other hosts so they all deploy the same revisions.
