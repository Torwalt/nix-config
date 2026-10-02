{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  seedSocke = pkgs.writeShellApplication {
    name = "seed-socke";
    runtimeInputs = with pkgs; [
      coreutils
      nixos-install-tools
      util-linux
    ];
    text = ''
      target="''${1:-/mnt}"
      repo="$HOME/nix-config"

      if ! mountpoint -q "$target"; then
        echo "seed-socke: nothing is mounted at $target" >&2
        echo "Partition the free space first, then mount the new root at" >&2
        echo "$target and the existing EFI system partition at $target/boot/efi." >&2
        echo "Do not format the ESP: Windows boots from it." >&2
        exit 1
      fi

      if [ ! -d "$repo" ]; then
        # -L: /etc/nix-config is a symlink into the read-only store.
        cp -rL /etc/nix-config "$repo"
        chmod -R u+w "$repo"
      fi

      # Writing under $target needs root; the rest stays in the live user's home.
      sudo nixos-generate-config --root "$target"
      cp "$target/etc/nixos/hardware-configuration.nix" \
        "$repo/hosts/socke/hardware-configuration.nix"

      echo
      echo "Wrote $repo/hosts/socke/hardware-configuration.nix."
      echo "Check that grub.efiSupport in $repo/hosts/socke/configuration.nix"
      echo "matches how this machine boots, then install:"
      echo
      echo "  sudo nixos-install --flake $repo#sockeSys --root $target"
    '';
  };
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-base.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  # Nothing here ever imports a ZFS root, and this is the 26.11 default.
  boot.zfs.forceImportRoot = false;

  image.baseName = lib.mkForce "nixos-socke";

  # A live desktop, because partitioning next to Windows wants GParted and a
  # browser. Calamares is deliberately absent: this installs from the flake.
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    plasma-login-manager.enable = true;
    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  console.keyMap = lib.mkForce "de";
  services.xserver.xkb.layout = "de";

  # The flake travels on the stick, so the install needs no clone.
  environment.etc."nix-config".source = inputs.self;

  environment.systemPackages = with pkgs; [
    seedSocke
    git
    ntfs3g
    parted
  ];

  # Uncomment to carry socke's entire closure on the stick and install with no
  # network at all. Adds roughly 15 GB to the ISO and the same again to the
  # build host's store.
  # isoImage.storeContents = [
  #   inputs.self.nixosConfigurations.sockeSys.config.system.build.toplevel
  # ];
}
