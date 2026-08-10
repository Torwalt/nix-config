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

      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${codingAgentNotify}/bin/coding-agent-notify 'Claude Code'";
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
