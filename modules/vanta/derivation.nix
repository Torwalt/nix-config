{ stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook, osquery }:
let

  version = "2.7.1";

  src = ~/vanta-agent/vanta-amd64.deb;

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

  # Extract and copy executable in $out/bin
  installPhase = ''
        export $(cat .env | xargs)
        mkdir -p $out
        env
        dpkg -x $src $out
  '';

  meta = {
    description = "Vanta-Agent";
    homepage = "https://app.vanta.com/employee/onboarding";
    # license = licenses.mit;
    # maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
