{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSUserEnv {
  name = "nodejs-fhs";
  targetPkgs = pkgs: with pkgs; [ nodejs_18 pnpm binaryen ];
}).env

