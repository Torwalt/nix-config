{ }:

let
  pinnedNixpkgs = builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "nixpkgs-23.11-darwin";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-23.11-darwin";
    rev = "2e00ff706f6554ed78c5f37d400b2c0b4a02ea3f";
  };

  pkgs = import pinnedNixpkgs { system = "x86_64-linux"; };
in {
  # Export the specific Go version
  go = pkgs.go;

  # Optionally export the entire pkgs set if needed
  inherit pkgs;

  home = {
    packages = with pkgs; [ delve ];
    sessionPath = [ "$HOME/go/bin" ];
  };

  programs.go = {
    goBin = "go/bin";
    goPath = "go";
  };
}

