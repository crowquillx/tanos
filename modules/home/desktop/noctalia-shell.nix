{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  noctaliaEnable = get [ "desktop" "noctalia" "enable" ] (desktopEnabled && compositor == "niri");
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri" && noctaliaEnable) {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = get [ "desktop" "noctalia" "systemd" "enable" ] true;
      settings = get [ "desktop" "noctalia" "settings" ] { };
      colors = get [ "desktop" "noctalia" "colors" ] { };
      plugins = get [ "desktop" "noctalia" "plugins" ] { };
      pluginSettings = get [ "desktop" "noctalia" "pluginSettings" ] { };
      user-templates = get [ "desktop" "noctalia" "userTemplates" ] { };
    };
  };
}
