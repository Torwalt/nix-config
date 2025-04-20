{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ocaml
    dune_3
    ocamlPackages.utop
    ocamlPackages.merlin
    ocamlPackages.ocaml-lsp
    ocamlformat_0_26_1
    opam
  ];

  shellHook = ''
    echo "✅ OCaml 5.2 dev shell ready (LSP, dune, utop, formatter)"
  '';
}

