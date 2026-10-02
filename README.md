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

Dual boots alongside Windows on one disk. In Windows first:

1. Uninstall the Steam games. Proton cannot use an NTFS library, so the games
   get reinstalled on the Linux side.
2. Control Panel, Power Options, "Choose what the power buttons do",
   uncheck "Turn on fast startup". This is a Windows setting, not a BIOS one.
   Without it the NTFS partition is left dirty and Linux will not mount it.
3. Disk Management, shrink the Windows partition. Leave 500 GB or more.
4. Note the "BIOS Mode" row in `msinfo32` and the GPU in `dxdiag`.

In the BIOS: Secure Boot off.

Then boot the installer ISO below and partition the free space Windows left.
Mount the new root at `/mnt` and the **existing** EFI system partition at
`/mnt/boot/efi`. Do not format the ESP: Windows boots from it. Kernels do not
go there either, because a 100 MB OEM ESP cannot hold them, so `/boot` stays
on the root filesystem and GRUB reads it from ext4.

```console
seed-socke
```

That generates `hosts/socke/hardware-configuration.nix` from what is mounted
and prints the `nixos-install` command. The committed file it replaces is a
placeholder with deliberately invalid UUIDs. Keep `grub.efiSupport` in
`hosts/socke/configuration.nix` matching the BIOS mode from step 4.

Neither account has a password, so set them before rebooting. Otherwise both
are locked and the login screen cannot be passed:

```console
sudo nixos-enter --root /mnt -c 'passwd socke'
sudo nixos-enter --root /mnt -c 'passwd ada'
```

`socke` upgrades itself daily from the `socke-stable` branch with
`nixos-rebuild boot`, so a change lands on her next power-on and never
restarts anything under a running session. Push to that branch to release:

```console
git push origin master:socke-stable
```

Keeping the branch behind `master` is the point: a broken `master` does not
reach an unattended machine. Failed builds change nothing, and older
generations stay in the boot menu for 30 days.

## Installer ISO

`isoSys` builds a live image carrying this flake, so installing socke needs
neither a clone nor a plain NixOS install first.

```console
nix build .#nixosConfigurations.isoSys.config.system.build.isoImage
```

The image lands in `result/iso/`. It boots a live Plasma desktop on a German
keymap with GParted and Firefox, the flake at `/etc/nix-config`, and
`seed-socke` on the path. `seed-socke` copies the flake somewhere writable,
writes the hardware configuration and stops. It never partitions anything.

The install still downloads socke's closure. Uncomment `isoImage.storeContents`
in `hosts/iso/configuration.nix` to carry the whole closure on the stick and
install with no network, at roughly 15 GB of extra image.

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
