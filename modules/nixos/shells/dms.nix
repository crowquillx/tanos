{ lib, pkgs, config, options, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "desktop" "enable" ] true && get [ "desktop" "shell" ] "none" == "dms";

  dmsModule =
    inputs.dms.nixosModules.default
    or (inputs.dms.nixosModules.dank-material-shell or null);

  dmsPkg = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default or (pkgs.dms-shell or null);
  cupsPkHelperPkg = lib.attrByPath [ "cups-pk-helper" ] null pkgs;
  kimageformatsPkg =
    let
      kde6 = lib.attrByPath [ "kdePackages" "kimageformats" ] null pkgs;
      qt5 = lib.attrByPath [ "libsForQt5" "kimageformats" ] null pkgs;
    in
    if kde6 != null then kde6 else qt5;
in
{
  # `imports` must not depend on `config` (via `enabled`) or evaluation recurses.
  imports = lib.optionals (dmsModule != null) [ dmsModule ];

  config = lib.mkIf enabled (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cupsPkHelperPkg != null;
            message = "Could not resolve nixpkgs package 'cups-pk-helper'.";
          }
          {
            assertion = kimageformatsPkg != null;
            message = "Could not resolve nixpkgs package 'kdePackages.kimageformats' (or libsForQt5 fallback).";
          }
        ];

        environment.systemPackages =
          lib.optionals (dmsPkg != null) [ dmsPkg ]
          ++ lib.optionals (cupsPkHelperPkg != null) [ cupsPkHelperPkg ]
          ++ lib.optionals (kimageformatsPkg != null) [ kimageformatsPkg ];
      }
    ]
    // lib.optionalAttrs (options ? programs.dms-shell.enable) {
      programs.dms-shell.enable = true;
    }
  );
}
