{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "fast-font";
  version = "main";

  src = fetchFromGitHub {
    owner = "Born2Root";
    repo = "Fast-Font";
    rev = "f1ec8f9426c5907ac0e1f0d30464c5ac07c1f844";
    sha256 = "sha256-sbm3zOdvdrVA4j/oU1InQ04hroQw5XHlN9p233FU0TA=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/fast-font
    cp ${src}/Fast_Sans.ttf  $out/share/fonts/truetype/fast-font/
    cp ${src}/Fast_Serif.ttf $out/share/fonts/truetype/fast-font/
  '';

  meta = with lib; {
    description = "Fast-Font: a speed-reading bionic font family";
    homepage = "https://github.com/Born2Root/Fast-Font";
    license = licenses.mit;
    platforms = platforms.all;
  };
}

