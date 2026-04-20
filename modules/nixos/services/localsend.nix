{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  extraPackages = get [ "users" "extraPackages" ] [ ];
  enabled = builtins.elem "localsend" extraPackages;
in
{
  config = lib.mkIf enabled {
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];
  };
}
