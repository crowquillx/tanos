{ lib, options, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  enabled = get [ "features" "theme" "qt" "enable" ] true;
  hasIllogicalEnableOption = lib.hasAttrByPath [ "programs" "illogical-impulse" "enable" ] options;
in
{
  config = lib.mkIf (desktopEnabled && enabled && !hasIllogicalEnableOption) {
    qt.enable = true;
  };
}
