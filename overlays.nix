{ inputs }:
[
  (final: prev: {
    codex = final.stdenv.mkDerivation {
      pname = "codex";
      version = "0.162.1";
      src = final.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v0.162.1/codex-package-x86_64-unknown-linux-musl.tar.zst";
        hash = "sha256-vSTQK+Z4iUtHvFZb0tqNR6BeOn3Qtu9mqpVymbJOyPI=";
      };
      nativeBuildInputs = with final; [
        zstd
        patchelf
        makeWrapper
      ];
      sourceRoot = ".";
      dontBuild = true;
      dontStrip = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin $out/lib/codex
        cp -r ./* $out/lib/codex/
        voice=$out/lib/codex/codex-resources/voice
        patchelf --set-interpreter ${final.stdenv.cc.bintools.dynamicLinker} \
          --add-rpath ${final.lib.getLib final.glibc}/lib \
          "$voice/bin/codex-voice-host"
        wrapProgram "$voice/bin/codex-voice-host" \
          --set ALSA_CONFIG_PATH ${final.writeText "codex-asound.conf" ''
            <${final.alsa-lib}/share/alsa/alsa.conf>
            !@hooks []
            defaults.namehint.showall on
            defaults.namehint.basic on
            defaults.namehint.extended on
            pcm_type.pipewire { lib "${final.pipewire}/lib/alsa-lib/libasound_module_pcm_pipewire.so" }
            ctl_type.pipewire { lib "${final.pipewire}/lib/alsa-lib/libasound_module_ctl_pipewire.so" }
            pcm.!default {
              type pipewire
              hint { show on description "PipeWire" }
            }
            ctl.!default { type pipewire }
          ''}
        makeWrapper "$out/lib/codex/bin/codex" "$out/bin/codex" \
          --set DISABLE_AUTOUPDATER 1 \
          --prefix PATH : ${final.lib.makeBinPath [ final.bubblewrap ]}
        ln -s ../lib/codex/bin/codex-code-mode-host $out/bin/codex-code-mode-host
        runHook postInstall
      '';
      meta = prev.codex.meta;
    };
    godiff = inputs.godiff.packages.${final.stdenv.hostPlatform.system}.default;
    spool = inputs.spool.packages.${final.stdenv.hostPlatform.system}.default;
  })
  (final: prev: {
    hawk-cli = prev.rustPlatform.buildRustPackage rec {
      pname = "hawk";
      version = "0.1.4";
      src = prev.fetchFromGitHub {
        owner = "rawnly";
        repo = "hawk";
        rev = "${version}";
        sha256 = "sha256-5ZsOJxmjwbCv8/mbz//0+CHcPYcTh+nvIt5gOkRQdOo=";
      };
      cargoHash = "sha256-Gbg+LsLX4tWRs7U6iPV5IDCA05C2v9rK7KQvqGdfXpQ=";
    };
  })
]
