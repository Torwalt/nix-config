{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSEnv {
  name = "nodejs-fhs";
  targetPkgs = pkgs: with pkgs; [ nodejs_24 pnpm binaryen ];
}).env

