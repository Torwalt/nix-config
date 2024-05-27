# taken from https://www.reddit.com/r/NixOS/comments/14dlvbr/comment/jyof3rf/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
{ qtbase, qtsvg, qtgraphicaleffects, qtquickcontrols2, wrapQtAppsHook
, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "tokyo-night-sddm";
  version = "1..0";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "rototrash";
    repo = "tokyo-night-sddm";
    rev = "320c8e74ade1e94f640708eee0b9a75a395697c6";
    sha256 = "sha256-JRVVzyefqR2L3UrEK2iWyhUKfPMUNUnfRZmwdz05wL0=";
  };
  nativeBuildInputs = [ wrapQtAppsHook ];

  propagatedUserEnvPkgs = [ qtbase qtsvg qtgraphicaleffects qtquickcontrols2 ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/tokyo-night-sddm
  '';
}
