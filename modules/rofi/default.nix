{ lib, pkgs, ... }:

let
  # oomd kills whole cgroups, so apps leave Hyprland's session scope.
  launchScoped = pkgs.writeShellScript "rofi-launch-scoped" ''
    name=$(${pkgs.coreutils}/bin/basename "$1")
    exec ${pkgs.systemd}/bin/systemd-run --user --scope --collect --quiet \
      --slice=app.slice \
      --unit="app-rofi-$(${pkgs.systemd}/bin/systemd-escape "$name")-$RANDOM" \
      -- "$@"
  '';
in
{
  programs.rofi = {
    enable = true;
    font = lib.mkForce "DejaVu Sans Mono 15";
    extraConfig.run-command = "${launchScoped} {cmd}";
  };
}
