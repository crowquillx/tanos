{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "nh" "enable" ] true;
  cleanEnable = get [ "features" "nh" "clean" "enable" ] true;
  cleanExtraArgs = get [ "features" "nh" "clean" "extraArgs" ] "--keep-since 4d --keep 3";
  repoRoot = ../../..;
in
{
  config = lib.mkIf enabled {
    programs.nh = {
      enable = true;
      flake = builtins.toString repoRoot;
      clean = {
        enable = cleanEnable;
        extraArgs = cleanExtraArgs;
      };
    };
  };
}
