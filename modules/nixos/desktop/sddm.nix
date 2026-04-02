{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  dm = get [ "desktop" "displayManager" ] "auto";
  compositor = get [ "desktop" "compositor" ] "niri";
  effectiveDm = if dm == "auto" then "sddm" else dm;
  defaultSession =
    if compositor == "plasma" then
      "plasma"
    else
      "niri";
in
{
  config = lib.mkIf (desktopEnabled && effectiveDm == "sddm") {
    services.xserver.enable = true;

    services.displayManager = {
      inherit defaultSession;
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
