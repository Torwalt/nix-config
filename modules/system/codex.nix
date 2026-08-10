{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  codingAgentNotify = import ../lib/coding-agent-notify.nix {
    inherit pkgs;
    tmux = pkgs-unstable.tmux;
  };
  tomlFormat = pkgs.formats.toml { };
in
{
  # Keep immutable defaults in the system config so Codex can use its writable
  # user config exclusively for mutable state such as directory trust.
  environment.etc."codex/config.toml".source = tomlFormat.generate "codex-config" {
    model = "gpt-5.6-sol";
    model_reasoning_effort = "high";
    personality = "pragmatic";
    sandbox_mode = "danger-full-access";
    notify = [
      "${codingAgentNotify}/bin/coding-agent-notify"
      "Codex"
    ];
  };
}
