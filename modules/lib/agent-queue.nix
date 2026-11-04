{
  pkgs,
  tmux,
  # Hyprland workspace of the terminal that runs tmux; jumps switch to it
  # before focusing the terminal window.
  terminalWorkspace ? null,
}:

pkgs.writeShellApplication {
  name = "agent-queue";
  runtimeInputs = with pkgs; [
    coreutils
    gawk
    gnugrep
    jq
    libnotify
    procps
    tmux
    util-linux
  ];
  text =
    pkgs.lib.optionalString (terminalWorkspace != null) ''
      terminal_workspace=${pkgs.lib.escapeShellArg terminalWorkspace}
    ''
    + builtins.readFile ./agent-queue.sh;
}
