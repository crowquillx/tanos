{
  inputs,
  lib,
  pkgs,
}:
let
  opencodePkgs = import inputs.opencode.inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  bun = opencodePkgs.bun.overrideAttrs (_: {
    version = "1.3.13";
    src =
      {
        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-linux-x64.zip";
          hash = "sha256-ecB3H6i5LDOq5B4VoODTB+qZ0OLwAxfHHGxTI3p44lo=";
        };
      }
      .${pkgs.stdenv.hostPlatform.system}
        or (throw "Unsupported opencode Bun platform: ${pkgs.stdenv.hostPlatform.system}");
  });
  opencodeNodeModules =
    {
      stdenvNoCC,
      bun,
      opencodeSrc,
      rev ? opencodeSrc.shortRev or (opencodeSrc.rev or "dirty"),
    }:
    let
      packageJson = lib.pipe (opencodeSrc + "/packages/opencode/package.json") [
        builtins.readFile
        builtins.fromJSON
      ];
      platform = stdenvNoCC.hostPlatform;
      bunCpu = if platform.isAarch64 then "arm64" else "x64";
      bunOs = if platform.isLinux then "linux" else "darwin";
    in
    stdenvNoCC.mkDerivation {
      pname = "opencode-node_modules";
      version = "${packageJson.version}+${lib.replaceString "-" "." rev}";
      src = lib.sources.cleanSource opencodeSrc;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [ bun ];

      dontConfigure = true;
      buildPhase = ''
        runHook preBuild
        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="${bunCpu}" \
          --os="${bunOs}" \
          --filter './' \
          --filter './packages/opencode' \
          --filter './packages/desktop' \
          --filter './packages/app' \
          --filter './packages/shared' \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress
        bun --bun ${opencodeSrc + "/nix/scripts/canonicalize-node-modules.ts"}
        bun --bun ${opencodeSrc + "/nix/scripts/normalize-bun-binaries.ts"}
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;
        runHook postInstall
      '';

      dontFixup = true;

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash =
        if stdenvNoCC.hostPlatform.isDarwin then
          "sha256-t16bjKN5f/GCRmIyjv9/RG7PsYLQjUxeAvqo3uG0l9c="
        else
          "sha256-L+tzQbIwYxp52lrDPSs5D1ceffHyTnpkc2Lo7cNh0ik=";
      meta.platforms = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
  node_modules = pkgs.callPackage opencodeNodeModules {
    inherit bun;
    opencodeSrc = inputs.opencode;
  };
in
pkgs.callPackage (inputs.opencode + "/nix/opencode.nix") {
  inherit bun node_modules;
}
