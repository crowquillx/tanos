{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "tailscale" "enable" ] true;
in
{
  config = lib.mkIf enabled {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraUpFlags = [ "--accept-routes" ];
    };
  };
}
