{ pkgs, ... }:

let
  # Resident plus swapped memory of one content process.
  limitGiB = 10;

  guard = pkgs.writeShellScript "firefox-tab-guard" ''
    limit_kib=$(( ${toString limitGiB} * 1024 * 1024 ))

    while true; do
      for dir in /proc/[0-9]*; do
        { read -r comm < "$dir/comm"; } 2>/dev/null || continue
        case "$comm" in
          "Isolated Web Co" | "Web Content") ;;
          *) continue ;;
        esac

        rss=0
        swap=0
        {
          while read -r key value _; do
            case "$key" in
              VmRSS:) rss=$value ;;
              VmSwap:) swap=$value ;;
            esac
          done < "$dir/status"
        } 2>/dev/null

        used=$(( rss + swap ))
        if (( used > limit_kib )); then
          pid=''${dir#/proc/}
          kill -KILL "$pid" 2>/dev/null || continue
          echo "killed $comm $pid at $(( used / 1024 )) MiB"
          ${pkgs.libnotify}/bin/notify-send -u critical "Firefox tab killed" \
            "Content process $pid used $(( used / 1024 / 1024 )) GiB (limit ${toString limitGiB} GiB)."
        fi
      done

      sleep 5
    done
  '';
in
{
  systemd.user.services.firefox-tab-guard = {
    Unit.Description = "Kill Firefox content processes above ${toString limitGiB} GiB";

    Service = {
      ExecStart = "${guard}";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
