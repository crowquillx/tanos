{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  packageNames = get [ "users" "extraPackages" ] [ ];

  resolvePkg = name: lib.attrByPath (lib.splitString "." name) null pkgs;
  missingPackageNames = lib.filter (name: resolvePkg name == null) packageNames;
  resolvedPackages = lib.filter (pkg: pkg != null) (map resolvePkg packageNames);
in
{
  assertions = [
    {
      assertion = missingPackageNames == [ ];
      message = "Unknown users.extraPackages entries: ${lib.concatStringsSep ", " missingPackageNames}";
    }
  ];

  home.packages = resolvedPackages;
}
