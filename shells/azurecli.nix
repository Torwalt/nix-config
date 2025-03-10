{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    azure-cli
    (python312.withPackages (ps: with ps; [ pip ]))
  ];

  shellHook = ''
    # Make sure pip is properly linked
    export PYTHONPATH=${pkgs.python312Packages.pip}/lib/python3.12/site-packages:$PYTHONPATH

    # Create directories Azure CLI might need
    mkdir -p $HOME/.azure/cliextensions

    echo "NixOS development environment with Azure CLI and Python 3.12 with pip is ready"
  '';
}

