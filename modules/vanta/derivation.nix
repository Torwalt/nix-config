{ stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook, osquery, }:
let

  version = "2.8.1";

  src = /home/ada/vanta-agent/vanta-amd64.deb;

in stdenv.mkDerivation {
  name = "Vanta-Agent-${version}";

  system = "x86_64-linux";

  inherit src;

  # Required for compilation
  nativeBuildInputs = [
    autoPatchelfHook # Automatically setup the loader, and do the magic
    dpkg
  ];

  # Required at running time
  buildInputs = [ glibc gcc-unwrapped osquery ];

  unpackPhase = "true";

  installPhase = ''
            export $(cat .env | xargs)
            mkdir $out
            dpkg -x $src $out
            mv $out/var/vanta/* $out
            mkdir $out/log
            touch $out/log/$(date +"%Y-%-m-%-d-0")
  '';

  meta = {
    description = "Vanta-Agent";
    homepage = "https://app.vanta.com/employee/onboarding";
    platforms = [ "x86_64-linux" ];
  };
}
