{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

# Coding agents that wait for the user queue up oldest first; Alt+A jumps to
# the next one and waybar shows how many wait.
let
  agentQueue = import ../../lib/agent-queue.nix {
    inherit pkgs;
    tmux = pkgs-unstable.tmux;
  };
  bin = "${agentQueue}/bin/agent-queue";
in
{
  home.packages = [ agentQueue ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, A, exec, ${bin} next"
    "$mainMod SHIFT, A, exec, ${bin} pick"
  ];

  programs.tmux.extraConfig = ''
    # Jump to the agent that has waited longest.
    bind-key a run-shell -b "${bin} next"
  '';

  programs.waybar.settings.mainBar = {
    modules-right = lib.mkBefore [ "custom/agent-queue" ];
    "custom/agent-queue" = {
      exec = "${bin} waybar";
      return-type = "json";
      # The age of the oldest entry ticks; pushes and drops signal at once.
      interval = 30;
      signal = 10;
      on-click = "${bin} next";
      on-click-middle = "${bin} pick";
      on-click-right = "${bin} clear";
    };
  };

  programs.waybar.style = lib.mkAfter ''
    #custom-agent-queue {
      padding: 0 5px;
    }

    #custom-agent-queue.waiting {
      color: @base0A;
    }
  '';
}
