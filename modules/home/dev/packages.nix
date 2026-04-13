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

  system = pkgs.stdenv.hostPlatform.system;
  vscodePkg = lib.attrByPath [ "vscode" ] null pkgs;
  geminiCliPkg =
    let
      sourcePkg = lib.attrByPath [ "gemini-cli" ] null pkgs;
      binPkg = lib.attrByPath [ "gemini-cli-bin" ] null pkgs;
    in
    if sourcePkg != null then sourcePkg else binPkg;
  antigravityPkg =
    let
      fhsPkg = lib.attrByPath [ "antigravity-fhs" ] null pkgs;
      nativePkg = lib.attrByPath [ "antigravity" ] null pkgs;
    in
    if fhsPkg != null then fhsPkg else nativePkg;
  bubblewrapPkg = lib.attrByPath [ "bubblewrap" ] null pkgs;
  statixPkg = lib.attrByPath [ "statix" ] null pkgs;
  opencodePkg = lib.attrByPath [ "opencode" ] null pkgs;
  uvPkg = lib.attrByPath [ "uv" ] null pkgs;
  deadnixPkg = lib.attrByPath [ "deadnix" ] null pkgs;
  alejandraPkg = lib.attrByPath [ "alejandra" ] null pkgs;
  nixfmtPkg = lib.findFirst (pkg: pkg != null) null [
    (lib.attrByPath [ "nixfmt" ] null pkgs)
    (lib.attrByPath [ "nixfmt-classic" ] null pkgs)
    (lib.attrByPath [ "nixfmt-rfc-style" ] null pkgs)
  ];
  nixLspPkg = lib.findFirst (pkg: pkg != null) null [
    (lib.attrByPath [ "nixd" ] null pkgs)
    (lib.attrByPath [ "nil" ] null pkgs)
  ];
  t3DesktopPkg = lib.findFirst (pkg: pkg != null) null [
    (lib.attrByPath [ "t3code-nix" "packages" system "t3code" ] null inputs)
    (lib.attrByPath [ "t3code-nix" "packages" system "t3code-desktop" ] null inputs)
    (lib.attrByPath [ "t3code-nix" "packages" system "default" ] null inputs)
  ];
  ghPkg = lib.attrByPath [ "gh" ] null pkgs;
  skillsPkg = lib.attrByPath [ "skills" ] null pkgs;
  copilotCliPkg = lib.attrByPath [ "copilot-cli-nix" "packages" system "default" ] null inputs;
in
{
  assertions = [
    {
      assertion = !(codingToolsEnabled && vscodePkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'vscode' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && geminiCliPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'gemini-cli' (or gemini-cli-bin fallback) could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && antigravityPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'antigravity-fhs' (preferred) or 'antigravity' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && bubblewrapPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'bubblewrap' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && statixPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'statix' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && deadnixPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'deadnix' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && alejandraPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'alejandra' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && nixfmtPkg == null);
      message = "features.codingTools.enable is true, but no nixfmt package could be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && nixLspPkg == null);
      message = "features.codingTools.enable is true, but no Nix language server (nixd or nil) could be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && t3DesktopPkg == null);
      message = "features.codingTools.enable is true, but no T3 Code desktop package could be resolved from t3code-nix.";
    }
    {
      assertion = !(codingToolsEnabled && ghPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'gh' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && skillsPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'skills' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && copilotCliPkg == null);
      message = "features.codingTools.enable is true, but no Copilot CLI package could be resolved from copilot-cli-nix.";
    }
  ];

  home.packages =
    lib.optionals (codingToolsEnabled && vscodePkg != null) [ vscodePkg ]
    ++ lib.optionals (codingToolsEnabled && geminiCliPkg != null) [ geminiCliPkg ]
    ++ lib.optionals (codingToolsEnabled && opencodePkg != null) [ opencodePkg ]
    ++ lib.optionals (codingToolsEnabled && uvPkg != null) [ uvPkg ]
    ++ lib.optionals (codingToolsEnabled && antigravityPkg != null) [ antigravityPkg ]
    ++ lib.optionals (codingToolsEnabled && bubblewrapPkg != null) [ bubblewrapPkg ]
    ++ lib.optionals (codingToolsEnabled && statixPkg != null) [ statixPkg ]
    ++ lib.optionals (codingToolsEnabled && deadnixPkg != null) [ deadnixPkg ]
    ++ lib.optionals (codingToolsEnabled && alejandraPkg != null) [ alejandraPkg ]
    ++ lib.optionals (codingToolsEnabled && nixfmtPkg != null) [ nixfmtPkg ]
    ++ lib.optionals (codingToolsEnabled && nixLspPkg != null) [ nixLspPkg ]
    ++ lib.optionals (codingToolsEnabled && t3DesktopPkg != null) [ t3DesktopPkg ]
    ++ lib.optionals (codingToolsEnabled && ghPkg != null) [ ghPkg ]
    ++ lib.optionals (codingToolsEnabled && skillsPkg != null) [ skillsPkg ]
    ++ lib.optionals (codingToolsEnabled && copilotCliPkg != null) [ copilotCliPkg ];

  xdg.desktopEntries = lib.optionalAttrs (codingToolsEnabled && t3DesktopPkg != null) {
    t3code = {
      name = "T3 Code";
      comment = "T3 Code desktop build";
      exec = "t3code --no-sandbox %U";
      terminal = false;
      type = "Application";
      categories = [ "Development" ];
      icon = "${t3DesktopPkg}/share/pixmaps/t3code.png";
      settings = {
        StartupWMClass = "t3-code-desktop";
      };
    };
  };
}
