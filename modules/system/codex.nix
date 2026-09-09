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
    developer_instructions = ''
      When creating commits, do not add AI authorship or attribution to the
      commit message. Do not add Co-authored-by trailers for Codex or any other
      AI assistant. Preserve the user's configured Git author and committer
      identity.
    '';
    notify = [
      "${codingAgentNotify}/bin/coding-agent-notify"
      "Codex"
      "Task finished"
    ];
    tui.status_line = [
      "model-with-reasoning"
      "context-remaining"
      "five-hour-limit"
      "weekly-limit"
    ];

    hooks = {
      PermissionRequest = [
        {
          hooks = [
            {
              type = "command";
              command = "${codingAgentNotify}/bin/coding-agent-notify Codex 'Action required'";
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "^request_user_input$";
          hooks = [
            {
              type = "command";
              command = "${codingAgentNotify}/bin/coding-agent-notify Codex 'Decision required'";
            }
          ];
        }
      ];
    };
  };
}
