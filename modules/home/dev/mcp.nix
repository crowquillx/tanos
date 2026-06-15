{
  lib,
  pkgs,
  vars ? {},
  inputs,
  ...
}: let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  codingToolsEnabled = get ["features" "codingTools" "enable"] true;
  aiCliEnabled = get ["features" "codingTools" "aiCli" "enable"] codingToolsEnabled;
  codexEnabled = get ["features" "codingTools" "aiCli" "codex" "enable"] aiCliEnabled;
  opencodeEnabled = get ["features" "codingTools" "aiCli" "opencode" "enable"] aiCliEnabled;
  nixosMcpEnabled = get ["features" "mcp" "nixos" "enable"] aiCliEnabled;
  opencodePkg = lib.attrByPath ["opencode"] null pkgs;
  codexPkg = lib.attrByPath ["codex"] null pkgs;
in {
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(codexEnabled && codexPkg == null);
          message = "features.codingTools.aiCli.codex.enable is true, but nixpkgs package 'codex' could not be resolved.";
        }
        {
          assertion = !(opencodeEnabled && opencodePkg == null);
          message = "features.codingTools.aiCli.opencode.enable is true, but nixpkgs package 'opencode' could not be resolved.";
        }
      ];
    }
    (lib.mkIf codexEnabled {
      programs.codex = {
        enable = true;
        package = codexPkg;
        enableMcpIntegration = nixosMcpEnabled;
      };
    })
    (lib.mkIf opencodeEnabled {
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
