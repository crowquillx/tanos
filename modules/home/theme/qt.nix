{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  enabled = get [ "features" "theme" "qt" "enable" ] true;
in
{
  config = lib.mkIf (desktopEnabled && enabled) {
    qt.enable = true;
    home.sessionVariables.QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
  };
}
