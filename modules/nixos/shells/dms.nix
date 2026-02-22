{ lib, pkgs, config, options, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "desktop" "enable" ] true && get [ "desktop" "shell" ] "none" == "dms";

  dmsModule =
    inputs.dms.nixosModules.default
    or (inputs.dms.nixosModules.dank-material-shell or null);

  dmsPkg = inputs.dms.packages.${pkgs.system}.default or (pkgs.dms-shell or null);
in
{
  # `imports` must not depend on `config` (via `enabled`) or evaluation recurses.
  imports = lib.optionals (dmsModule != null) [ dmsModule ];

  config = lib.mkIf enabled (
    {
      environment.systemPackages = lib.optionals (dmsPkg != null) [ dmsPkg ];
    }
    // lib.optionalAttrs (options ? programs.dms-shell.enable) {
      programs.dms-shell.enable = true;
    }
  );
}
