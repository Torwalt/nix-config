{ pkgs, ... }:
let
  yubikeySetup = pkgs.writeShellApplication {
    name = "yubikey-setup";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      python3
      yubikey-manager
    ];
    text = builtins.readFile ./scripts/yubikey-setup.sh;
  };

  kdbxYubikey = pkgs.writeShellApplication {
    name = "kdbx-yubikey";
    runtimeInputs = with pkgs; [
      coreutils
      diffutils
      gnugrep
      keepassxc
      yubikey-manager
    ];
    text = builtins.readFile ./scripts/kdbx-yubikey.sh;
  };

  kdbxBackup = pkgs.writeShellApplication {
    name = "kdbx-backup";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      jq
      keepassxc
      python3
      udisks
      util-linux
      yubikey-manager
    ];
    text = builtins.readFile ./scripts/kdbx-backup.sh;
  };
in
{
  home.packages = [
    pkgs.yubikey-manager
    yubikeySetup
    kdbxYubikey
    kdbxBackup
  ];
}
