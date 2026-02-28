{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  dm = get [ "desktop" "displayManager" ] "auto";
  effectiveDm = if dm == "auto" then "sddm" else dm;
in
{
  config = lib.mkIf (desktopEnabled && effectiveDm == "sddm") {
    services.xserver.enable = true;

    services.displayManager = {
      defaultSession = "hyprland";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
