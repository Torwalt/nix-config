{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      aider-chat
      claude-code
      libnotify
      pi-coding-agent
    ];

    file.".claude/settings.json".text =
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
                  command = "${pkgs.libnotify}/bin/notify-send 'Claude Code' 'Task finished'";
                }
              ];
            }
          ];
          Notification = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = "${pkgs.libnotify}/bin/notify-send 'Claude Code' 'Claude needs your attention'";
                }
              ];
            }
          ];
        };
      }
      + "\n";

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
