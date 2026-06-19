{ lib, config, pkgs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  extraPackages = get [ "users" "extraPackages" ] [ ];
  enabled = builtins.elem "mullvad-vpn" extraPackages;
in
{
  config = lib.mkIf enabled {
    services.mullvad-vpn = {
      enable = true;
      package = lib.getAttr "mullvad-vpn" pkgs;
    };
  };
}
