{
  lib,
  pkgs,
  ...
}:
let
  karrtRevision = "f5a7b80e3e9883fa47bad78bd62be1765bb905c1";
  solverRevision = "a0234a982f55842277e00b38b61bc9335026823d";
  skillRevision = "695a2786f3b8cda3d8eb8f7b4ae9981eb3abb6da";

  captchaSolver = pkgs.fetchFromGitHub {
    owner = "Tobi4s1337";
    repo = "2captcha-solver-mirror";
    rev = solverRevision;
    hash = "sha256-xRmioDATp+V5IYVwFaoi9durXYjvfTbCCTTSuME5asA=";
  };

  karrt = pkgs.buildNpmPackage {
    pname = "karrt";
    version = "0.2.0-unstable-2026-04-29";

    src = pkgs.fetchFromGitHub {
      owner = "Tobi4s1337";
      repo = "karrt";
      rev = karrtRevision;
      hash = "sha256-lELeYl12OV6DhJxyXKh8GCGadxmPJ1YlMc6Yz7etLYE=";
    };

    npmDepsHash = "sha256-8tFHIbRKRfaixqG7rTdfLMNFr3EG9h/oIXALwXQgjRw=";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

    postPatch = ''
      substituteInPlace src/auth/index.ts \
        --replace-fail \
          'const EXTENSION_PATH = resolve(__dirname, "../../2captcha-solver");' \
          'const EXTENSION_PATH = process.env.KARRT_EXTENSION_PATH ?? resolve(__dirname, "../../2captcha-solver");'
      substituteInPlace src/auth/index.ts \
        --replace-fail \
          'const userDataDir = resolve(__dirname, "../../.chrome-data");' \
          'const userDataDir = resolve(process.env.XDG_CONFIG_HOME ?? resolve(process.env.HOME ?? ".", ".config"), "karrt/chrome-data");'
      substituteInPlace src/auth/index.ts \
        --replace-fail \
          'headless: false as const,' \
          'headless: false as const, executablePath: process.env.KARRT_CHROMIUM_PATH,'
    '';

    postInstall = ''
      wrapProgram $out/bin/karrt \
        --run 'karrtConfigDir="''${XDG_CONFIG_HOME:-$HOME/.config}/karrt"' \
        --run 'karrtExtensionDir="$karrtConfigDir/2captcha-solver"' \
        --run 'if [ ! -e "$karrtExtensionDir/manifest.json" ]; then ${pkgs.coreutils}/bin/mkdir -p "$karrtConfigDir"; ${pkgs.coreutils}/bin/cp -R ${captchaSolver} "$karrtExtensionDir"; ${pkgs.coreutils}/bin/chmod -R u+w "$karrtExtensionDir"; fi' \
        --run 'export KARRT_EXTENSION_PATH="$karrtExtensionDir"' \
        --set-default KARRT_CHROMIUM_PATH ${lib.getExe pkgs.chromium}
    '';

    meta = {
      description = "REWE Pickup CLI for AI agents";
      homepage = "https://github.com/Tobi4s1337/karrt";
      license = lib.licenses.mit;
      mainProgram = "karrt";
      platforms = lib.platforms.linux;
    };
  };

  karrtSkill = pkgs.runCommand "karrt-agent-skill-${skillRevision}" { } ''
    cp -r ${
      pkgs.fetchFromGitHub {
        owner = "Tobi4s1337";
        repo = "karrt-skill";
        rev = skillRevision;
        hash = "sha256-O05QEYW/UgVaKuj8NBCyKZnkRkRc7adYO/QpyqSmqWc=";
      }
    }/skills/karrt $out
    chmod -R u+w $out

    substituteInPlace $out/SKILL.md \
      --replace-fail 'via the `karrt` CLI at `~/karrt`' 'via the `karrt` CLI available on PATH' \
      --replace-fail 'All commands are run from this directory using `node dist/cli.js` (or just `karrt` if linked).' 'Run commands directly with `karrt`.' \
      --replace-fail 'If the CLI is not installed yet (no `~/karrt/dist/` directory)' 'If the CLI is not installed yet (`command -v karrt` fails)' \
      --replace-warn 'cd ~/karrt && node dist/cli.js' 'karrt'

    substituteInPlace $out/references/setup.md \
      --replace-warn 'if a step is already done (e.g., `dist/cli.js` exists)' 'if a step is already done (e.g., `command -v karrt` succeeds)' \
      --replace-warn '## 2. Install the 2Captcha browser extension' '## 2. Configure the 2Captcha browser extension' \
      --replace-warn '2. Download the extension from the [2captcha/solver_browser_extension releases](https://github.com/2captcha/solver_browser_extension/releases) — get the Chrome/Chromium `.zip` and extract it' '2. Run `karrt --version` once; the Nix wrapper installs the bundled extension into the writable config directory' \
      --replace-warn '3. Place the extracted folder at `~/.config/karrt/2captcha-solver/` (must contain a `manifest.json` file)' '3. Confirm that `~/.config/karrt/2captcha-solver/manifest.json` exists' \
      --replace-warn 'Configure the API key in `2captcha-solver/common/config.js`' 'Configure the API key in `~/.config/karrt/2captcha-solver/common/config.js`' \
      --replace-warn 'CLI cloned, installed, built (`command -v karrt` succeeds)' 'CLI installed (`command -v karrt` succeeds)' \
      --replace-warn 'cd ~/karrt && node dist/cli.js' 'karrt' \
      --replace-warn 'cd ~/karrt && xvfb-run node dist/cli.js login' 'xvfb-run karrt login' \
      --replace-warn '~/karrt/2captcha-solver/' '~/.config/karrt/2captcha-solver/' \
      --replace-warn '`~/karrt/dist/cli.js` exists' '`command -v karrt` succeeds' \
      --replace-warn 'git clone https://github.com/Tobi4s1337/karrt.git ~/karrt' '# Installed declaratively by Home Manager' \
      --replace-warn 'cd ~/karrt' 'command -v karrt' \
      --replace-warn 'npm install' 'karrt --version' \
      --replace-warn 'npx playwright install chromium' '# Chromium is supplied by Nix' \
      --replace-warn 'npm run build' '# The CLI is already built'
  '';
in
{
  home.packages = [ karrt ];

  home.file = {
    ".codex/skills/karrt".source = karrtSkill;
    ".claude-personal/skills/karrt".source = karrtSkill;
    ".claude-work/skills/karrt".source = karrtSkill;
    ".pi/agent/skills/karrt".source = karrtSkill;
  };
}
