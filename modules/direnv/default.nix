{ lib, ... }: {
    programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        # env vars need to be set like
        # `export VAR=x`
        config = lib.importTOML ./config.toml;
    };
}
