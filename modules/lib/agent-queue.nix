{ pkgs, tmux }:

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
  text = builtins.readFile ./agent-queue.sh;
}
