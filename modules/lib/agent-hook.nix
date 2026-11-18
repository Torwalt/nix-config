{ pkgs }:

let
  definitions = pkgs.writeTextDir "agent-hook.jq" (builtins.readFile ./agent-hook.jq);
in
pkgs.writeShellApplication {
  name = "agent-hook";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.jq
  ];
  text = ''
    # agent-hook DEFINITION: exit 0 when the hook payload on stdin satisfies
    # DEFINITION from agent-hook.jq. Without a payload (a terminal, Codex's
    # notify, which passes its JSON as an argument) nothing is satisfied.
    if [ $# -ne 1 ]; then
      echo "usage: agent-hook DEFINITION" >&2
      exit 2
    fi
    [ ! -t 0 ] || exit 1
    # A writer that never closes stdin must not hang the hook.
    payload="$(timeout 1 cat || true)"
    [ -n "$payload" ] || exit 1
    jq -e -L ${definitions} "include \"agent-hook\"; $1" <<<"$payload" >/dev/null 2>&1
  '';
}
