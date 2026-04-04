{
  lib,
  pkgs,
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
  codexPkg = lib.attrByPath [ "codex-cli-nix" "packages" system "default" ] null inputs;
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
        package = null;
        enableMcpIntegration = nixosMcpEnabled;
      };
    })
    (lib.mkIf nixosMcpEnabled {
      programs.mcp.enable = true;
      mcp-servers.programs.nixos.enable = true;
    })
  ];
}
