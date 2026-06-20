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
  opencodePkg = lib.attrByPath ["codex"] null pkgs;
  codexPkg = lib.attrByPath ["codex"] null pkgs;

  codexTrustedDirs = get ["features" "codingTools" "aiCli" "codex" "trustedDirectories"] [];
  codexModel = get ["features" "codingTools" "aiCli" "codex" "model"] "gpt-5.5";
  codexModelReasoningEffort = get ["features" "codingTools" "aiCli" "codex" "modelReasoningEffort"] "low";
  codexPlanModeReasoningEffort = get ["features" "codingTools" "aiCli" "codex" "planModeReasoningEffort"] "high";

  codexSettings = {
    model = codexModel;
    model_reasoning_effort = codexModelReasoningEffort;
    plan_mode_reasoning_effort = codexPlanModeReasoningEffort;
  } // lib.optionalAttrs (codexTrustedDirs != []) {
    projects = lib.genAttrs codexTrustedDirs (_: { trust_level = "trusted"; });
  };
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
        settings = codexSettings;
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
