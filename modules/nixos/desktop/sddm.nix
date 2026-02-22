{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  shell = get [ "desktop" "shell" ] "none";
  dm = get [ "desktop" "displayManager" ] "auto";
  effectiveDm =
    if dm == "auto"
    then if shell == "dms" then "dms-greeter" else "sddm"
    else dm;
in
{
  config = lib.mkIf (desktopEnabled && effectiveDm == "sddm") {
    services.xserver.enable = true;

    services.displayManager = {
      defaultSession = "niri";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
