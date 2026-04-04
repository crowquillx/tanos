{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  forceIfConfigured = value: if value == { } then value else lib.mkForce value;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  noctaliaEnable = get [ "desktop" "noctalia" "enable" ] (desktopEnabled && compositor == "niri");
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri" && noctaliaEnable) {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = get [ "desktop" "noctalia" "systemd" "enable" ] true;
      settings = forceIfConfigured (get [ "desktop" "noctalia" "settings" ] { });
      colors = forceIfConfigured (get [ "desktop" "noctalia" "colors" ] { });
      plugins = forceIfConfigured (get [ "desktop" "noctalia" "plugins" ] { });
      pluginSettings = forceIfConfigured (get [ "desktop" "noctalia" "pluginSettings" ] { });
      user-templates = forceIfConfigured (get [ "desktop" "noctalia" "userTemplates" ] { });
    };
  };
}
