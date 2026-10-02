# Repository-level tasks. Per-host updates live in `nixup`.

_default:
    @just --list

# Format every Nix file in the tree.
fmt:
    nix fmt

# Evaluate every host and run the pre-commit hooks.
check:
    nix flake check

# Build one host without activating it, for example `just build towerSys`.
build host:
    nix build --no-link --print-out-paths \
        ".#nixosConfigurations.{{host}}.config.system.build.toplevel"

# Build the socke installer image into ./result.
iso:
    nix build .#nixosConfigurations.isoSys.config.system.build.isoImage
    @ls -lh result/iso/

# Write the built image to a stick, for example `just iso-write /dev/sdb`.
iso-write device:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f result/iso/nixos-socke.iso ]; then
        echo "no image built yet, run 'just iso'" >&2
        exit 1
    fi
    lsblk -do NAME,SIZE,MODEL,TRAN "{{device}}"
    read -rp "Erase {{device}} entirely? [y/N] " reply
    [ "$reply" = y ] || exit 1
    sudo dd if=result/iso/nixos-socke.iso of="{{device}}" bs=4M status=progress conv=fsync

# Release the current master to socke, which upgrades itself from it daily.
release-socke:
    git push origin master:socke-stable
