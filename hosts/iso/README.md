# Installing socke

`isoSys` is a live image carrying this flake, so installing `socke` needs
neither a clone nor a plain NixOS install first. It boots a Plasma desktop on
a German keymap with GParted and Firefox, the flake at `/etc/nix-config`, and
`seed-socke` on the path.

`socke` dual boots alongside Windows on one disk.

## Build the stick

The image snapshots the flake as it is committed, so push first.

```console
just iso
lsblk                      # confirm which device is the stick
just iso-write /dev/sdX
```

Push `socke-stable` now as well, or the first nightly upgrade runs against a
branch that does not exist.

```console
just release-socke
```

## Windows, in this order

1. Uninstall the Steam games. Proton cannot use an NTFS library, so they get
   reinstalled on the Linux side.
2. In an Administrator Command Prompt: `powercfg /h off`. This disables Fast
   Startup, which otherwise leaves the NTFS partition dirty and unmountable
   from Linux, and deletes `hiberfil.sys`, which otherwise blocks the shrink.
   Fast Startup is a Windows setting, not a BIOS one.
3. `msinfo32`, note the "BIOS Mode" row. `dxdiag`, Display tab, note the GPU.
4. `diskmgmt.msc`, right-click C:, Shrink Volume. Leave 500 GB or more. If it
   will not shrink far enough, turn off the page file and System Restore,
   reboot and retry.
5. Shut down.

In the BIOS: Secure Boot off, then boot the stick.

## Partition and mount

Connect to the network from Plasma's applet first. The install downloads
socke's closure unless the ISO was built with `isoImage.storeContents`.

In GParted, one ext4 partition in the unallocated space. A swap partition is
optional; `seed-socke` picks one up if it exists.

```console
lsblk -f
sudo mount /dev/nvme0n1pN /mnt            # the new ext4 partition
sudo mkdir -p /mnt/boot/efi
sudo mount /dev/nvme0n1p1 /mnt/boot/efi   # the existing Windows ESP
```

Do not `mkfs` the ESP. Windows boots from it, and an OEM ESP is around 100 MB,
far too small for NixOS kernels. Only GRUB's EFI stub goes there. `/boot` stays
on the root filesystem, which GRUB reads from ext4.

## Install

```console
seed-socke
```

That copies the flake to `~/nix-config` and writes
`hosts/socke/hardware-configuration.nix` from what is mounted, replacing a
placeholder that carries deliberately invalid UUIDs. It never partitions
anything.

Check that the generated file lists `/boot/efi` rather than `/boot`, and that
`grub.efiSupport` in `~/nix-config/hosts/socke/configuration.nix` matches the
BIOS mode from step 3.

```console
sudo nixos-install --flake /home/nixos/nix-config#sockeSys --root /mnt
```

`nixos-install` only sets root's password. Set the other two before rebooting,
or both accounts stay locked and the login screen cannot be passed.

```console
sudo nixos-enter --root /mnt -c 'passwd socke'
sudo nixos-enter --root /mnt -c 'passwd ada'
reboot
```

## First boot

If GRUB does not list Windows, that is os-prober failing inside the install
chroot rather than a broken configuration. Re-run it from the real system:

```console
sudo nixos-rebuild boot --flake github:Torwalt/nix-config/socke-stable#sockeSys
```

In Steam: Settings, Compatibility, enable Steam Play for all other titles and
select GE-Proton. Without it, anything outside Valve's whitelist offers no
Proton at all. Games reinstall to the Linux partition.

Confirm the upgrade timer with `systemctl status nixos-upgrade.timer`.
