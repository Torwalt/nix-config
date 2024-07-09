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

  # Extract and copy executable in $out/bin
  installPhase = ''
            export $(cat .env | xargs)
            mkdir $out
            dpkg -x $src $out
            mv $out/var/vanta/* $out
            mkdir $out/log
            touch $out/log/2024-7-8-0

            # cp -av $out/etc/* /etc
            # cp $out/var/vanta/* /var/vanta
            # cp -av $out/usr/* /usr
            # rm $out/osqueryd
            # ln -s /run/current-system/sw/bin/osqueryd $out/osqueryd
  '';

  meta = {
    description = "Vanta-Agent";
    homepage = "https://app.vanta.com/employee/onboarding";
    # license = licenses.mit;
    # maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
