{ lib, pkgs, config, inputs, ... }:
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
  primaryUser = get [ "users" "primary" ] "tan";
  compositor = get [ "desktop" "compositor" ] "niri";
in
{
  config = lib.mkIf (desktopEnabled && effectiveDm == "dms-greeter") {
    services.displayManager."dms-greeter" = {
      enable = true;
      compositor.name = compositor;
      configHome = "/home/${primaryUser}";
      package = inputs.dms.packages.${pkgs.system}.default;
    };
  };
}
