{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "flatpak" "enable" ] false;
in
{
  config = lib.mkIf enabled {
    services.flatpak.enable = true;
  };
}
