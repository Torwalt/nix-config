{ pkgs, ... }:
{
  # KeePassXC talks to the challenge-response slot over USB HID; these rules
  # give the logged-in user access to it.
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # ykman needs the smart card daemon for the FIDO, OpenPGP and PIV applets.
  services.pcscd.enable = true;

  # Lets kdbx-backup mount and power off thumb drives without root.
  services.udisks2.enable = true;
}
