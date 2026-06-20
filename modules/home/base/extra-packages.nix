{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  packageNames = get [ "users" "extraPackages" ] [ ];
  localsendEnabled = get [ "features" "localsend" "package" "enable" ] false;
  mullvadPackage = get [ "features" "mullvad" "package" ] "none";

  resolvePkg = name: lib.attrByPath (lib.splitString "." name) null pkgs;
  missingPackageNames = lib.filter (name: resolvePkg name == null) packageNames;
  resolvedPackages = lib.filter (pkg: pkg != null) (map resolvePkg packageNames);
  featurePackages =
    lib.optionals localsendEnabled [ pkgs.localsend ]
    ++ lib.optionals (mullvadPackage == "cli") [ pkgs.mullvad ]
    ++ lib.optionals (mullvadPackage == "gui") [ (lib.getAttr "mullvad-vpn" pkgs) ];
in
{
  assertions = [
    {
      assertion = missingPackageNames == [ ];
      message = "Unknown users.extraPackages entries: ${lib.concatStringsSep ", " missingPackageNames}";
    }
    {
      assertion = !(localsendEnabled && builtins.elem "localsend" packageNames);
      message = "LocalSend is declared twice; use features.localsend.package.enable instead of users.extraPackages.";
    }
    {
      assertion = !(mullvadPackage != "none" && builtins.any (name: builtins.elem name [ "mullvad" "mullvad-vpn" ]) packageNames);
      message = "Mullvad is declared twice; use features.mullvad.package instead of users.extraPackages.";
    }
  ];

  home.packages = resolvedPackages ++ featurePackages;
}
