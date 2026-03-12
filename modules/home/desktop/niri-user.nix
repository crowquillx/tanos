{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriSettings = get [ "desktop" "niri" "settings" ] { };
  niriOutputs = get [ "desktop" "niri" "outputs" ] { };
  effectiveNiriSettings = lib.recursiveUpdate niriSettings (lib.optionalAttrs (niriOutputs != { }) { outputs = niriOutputs; });
  hasNiriSettings = effectiveNiriSettings != { };
  niriPackage = lib.attrByPath [ "niri-unstable" ] null pkgs;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") (
    lib.mkMerge [
      {
        home.sessionVariables = {
          XDG_CURRENT_DESKTOP = lib.mkDefault "niri";
          XDG_SESSION_DESKTOP = lib.mkDefault "niri";
          NIXOS_OZONE_WL = lib.mkDefault "1";
          ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
        };
      }
      (lib.mkIf (niriPackage != null) {
        programs.niri.package = lib.mkDefault niriPackage;
      })
      (lib.mkIf hasNiriSettings {
        programs.niri.settings = effectiveNiriSettings;
      })
    ]
  );
}
