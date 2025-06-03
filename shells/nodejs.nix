{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSUserEnv {
  name = "nodejs-fhs";
  targetPkgs = pkgs: with pkgs; [ nodejs_24 pnpm binaryen ];
}).env

