{ pkgs, ... }:

let
  codexNotify = pkgs.writeShellApplication {
    name = "codex-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      notify-send \
        --app-name="Codex" \
        "Codex" \
        "Task finished"
    '';
  };

  codexAttention = pkgs.writeShellApplication {
    name = "codex-attention";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      notify-send \
        --app-name="Codex" \
        "Codex" \
        "Codex needs your attention"
    '';
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
    notify = [ "${codexNotify}/bin/codex-notify" ];
  };

  # Codex only treats hooks from the system requirements file as managed and
  # trusted. User-level hooks require mutable trust hashes in config.toml,
  # which conflicts with Home Manager's immutable generated config.
  environment.etc."codex/requirements.toml".source = tomlFormat.generate "codex-requirements" {
    features.hooks = true;

    hooks = {
      managed_dir = "${codexAttention}/bin";
      PermissionRequest = [
        {
          hooks = [
            {
              type = "command";
              command = "${codexAttention}/bin/codex-attention";
              timeout = 5;
            }
          ];
        }
      ];
    };
  };
}
