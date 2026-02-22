{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "zoxide" "enable" ] true;
  fishEnabled = get [ "features" "shell" "fish" "enable" ] true;
in
{
  config = lib.mkIf enabled {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = fishEnabled;
      enableBashIntegration = true;
    };
  };
}
