{ inputs }:
[
  (final: prev: {
    godiff = inputs.godiff.packages.${final.stdenv.hostPlatform.system}.default;
  })
  (final: prev: {
    hawk-cli = prev.rustPlatform.buildRustPackage rec {
      pname = "hawk";
      version = "0.1.4";
      src = prev.fetchFromGitHub {
        owner = "rawnly";
        repo = "hawk";
        rev = "${version}";
        sha256 = "sha256-5ZsOJxmjwbCv8/mbz//0+CHcPYcTh+nvIt5gOkRQdOo=";
      };
      cargoHash = "sha256-Gbg+LsLX4tWRs7U6iPV5IDCA05C2v9rK7KQvqGdfXpQ=";
    };
  })
]
