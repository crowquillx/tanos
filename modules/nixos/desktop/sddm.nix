{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  dm = get [ "desktop" "displayManager" ] "sddm";
in
{
  config = lib.mkIf (desktopEnabled && dm == "sddm") {
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
