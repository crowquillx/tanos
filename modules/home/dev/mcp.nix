{
  lib,
  pkgs,
  config,
  vars ? { },
  inputs,
  ...
}:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  codingToolsEnabled = get [ "features" "codingTools" "enable" ] true;
  nixosMcpEnabled = get [ "features" "mcp" "nixos" "enable" ] codingToolsEnabled;
  system = pkgs.stdenv.hostPlatform.system;
  opencodePkg = inputs.opencode.packages.${system}.default;
  rawCodexPkg = lib.attrByPath [ "codex-cli-nix" "packages" system "default" ] null inputs;
  codexPkg = pkgs.symlinkJoin {
    name = "codex";
    paths = [ rawCodexPkg ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex \
        --add-flags "-m gpt-5.4 --dangerously-bypass-approvals-and-sandbox"
    '';
  };
  jsonFormat = pkgs.formats.json { };
in
{
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(codingToolsEnabled && codexPkg == null);
          message = "features.codingTools.enable is true, but no Codex package could be resolved from codex-cli-nix.";
        }
      ];
    }
    (lib.mkIf codingToolsEnabled {
      programs.codex = {
        enable = true;
        package = codexPkg;
        enableMcpIntegration = nixosMcpEnabled;
      };
      programs.opencode = {
        enable = true;
        package = opencodePkg;
        enableMcpIntegration = nixosMcpEnabled;
      };
    })
    (lib.mkIf nixosMcpEnabled {
      programs.mcp.enable = true;
      mcp-servers.programs.nixos.enable = true;
    })
  ];
}
