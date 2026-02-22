{ lib, pkgs, config, options, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "desktop" "enable" ] true && get [ "desktop" "shell" ] "none" == "noctalia";

  noctaliaModule =
    inputs.noctalia.nixosModules.default
    or (inputs.noctalia.nixosModules.noctalia-shell or null);

  noctaliaPkg = inputs.noctalia.packages.${pkgs.system}.default or null;
in
{
  imports = lib.optionals (enabled && noctaliaModule != null) [ noctaliaModule ];

  config = lib.mkIf enabled (
    {
      environment.systemPackages = lib.optionals (noctaliaPkg != null) [ noctaliaPkg ];
    }
    // lib.optionalAttrs (options ? programs.noctalia-shell.enable) {
      programs.noctalia-shell.enable = true;
    }
    // lib.optionalAttrs (options ? services.noctalia-shell.enable) {
      services.noctalia-shell.enable = true;
    }
  );
}
