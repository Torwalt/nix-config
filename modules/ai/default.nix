{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      aider-chat
      pi-coding-agent
    ];

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
