{ lib, options, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  shell = get [ "desktop" "shell" ] "none";
  startupCommand =
    if shell == "none" then null
    else get [ "desktop" "shellStartupCommand" ] null;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri" && options ? programs.niri.settings) (
    lib.optionalAttrs (startupCommand != null) {
      programs.niri.settings."spawn-at-startup" = [
        { command = [ startupCommand ]; }
      ];
    }
  );
}
