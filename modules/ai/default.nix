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

  claudeStatusLine = pkgs.writeShellApplication {
    name = "claude-status-line";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      jq -r '
        (.rate_limits.five_hour.used_percentage? // null) as $fiveHourUsed
        | (.rate_limits.seven_day.used_percentage? // null) as $sevenDayUsed
        | [
            ((.model.display_name // .model.id // "Claude")
              + if .effort.level? then " " + .effort.level else "" end),
            ("Context " + ((.context_window.remaining_percentage // 0 | floor | tostring) + "% left")),
            (if $fiveHourUsed == null then empty else "5h " + (((100 - $fiveHourUsed) | floor | tostring) + "% left") end),
            (if $sevenDayUsed == null then empty else "weekly " + (((100 - $sevenDayUsed) | floor | tostring) + "% left") end)
          ]
        | join(" · ")
      '
    '';
  };

  claudeSettings =
    builtins.toJSON {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      enabledPlugins = {
        "gopls-lsp@claude-plugins-official" = true;
      };
      alwaysThinkingEnabled = true;
      tui = "default";
      skipDangerousModePermissionPrompt = true;
      editorMode = "vim";
      autoCompactEnabled = false;
      preferredNotifChannel = "terminal_bell";
      attribution.commit = "";
      statusLine = {
        type = "command";
        command = "${claudeStatusLine}/bin/claude-status-line";
      };

      hooks = {
        Elicitation = [
          {
            hooks = [
              {
                type = "command";
                command = "${codingAgentNotify}/bin/coding-agent-notify 'Claude Code' 'Decision required'";
              }
            ];
          }
        ];
        PermissionRequest = [
          {
            hooks = [
              {
                type = "command";
                command = "${codingAgentNotify}/bin/coding-agent-notify 'Claude Code' 'Action required'";
              }
            ];
          }
        ];
        PreToolUse = [
          {
            matcher = "AskUserQuestion|ExitPlanMode";
            hooks = [
              {
                type = "command";
                command = "${codingAgentNotify}/bin/coding-agent-notify 'Claude Code' 'Decision required'";
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${codingAgentNotify}/bin/coding-agent-notify 'Claude Code' 'Task finished'";
              }
            ];
          }
        ];
      };
    }
    + "\n";
in
{
  home = {
    packages = with pkgs; [
      aider-chat
      claude-code
      pi-coding-agent
    ];

    file.".claude-personal/settings.json" = {
      text = claudeSettings;
      force = true;
    };
    file.".claude-work/settings.json" = {
      text = claudeSettings;
      force = true;
    };

    file.".pi/agent/settings.json".text =
      builtins.toJSON {
        externalEditor = "nvim";
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        enableAnalytics = false;
      }
      + "\n";

    sessionVariables = {
      PI_SKIP_VERSION_CHECK = "1";
    };
  };
}
