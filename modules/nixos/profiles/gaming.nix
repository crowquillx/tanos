{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "gaming" "enable" ] false;
in
{
  config = lib.mkIf enabled {
    programs.steam.enable = true;
  };
}
