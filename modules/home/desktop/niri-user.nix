{ lib, pkgs, vars ? { }, inputs ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriSettings = get [ "desktop" "niri" "settings" ] { };
  niriOutputs = get [ "desktop" "niri" "outputs" ] { };
  niriSettingsBuilder = get [ "desktop" "niri" "settingsBuilder" ] null;
  defaultNiriConfigBuilder = import ./niri/default.nix;
  niriConfigBuilder = get [ "desktop" "niri" "configBuilder" ] defaultNiriConfigBuilder;
  callBuilder = builder:
    if builder == null then
      null
    else if builtins.isFunction builder then
      builder { inherit lib pkgs vars inputs; }
    else
      builder;
  builtNiriSettings = callBuilder niriSettingsBuilder;
  niriConfig = callBuilder niriConfigBuilder;
  effectiveNiriSettings =
    lib.recursiveUpdate
      (lib.recursiveUpdate niriSettings (lib.optionalAttrs (niriOutputs != { }) { outputs = niriOutputs; }))
      (if builtNiriSettings == null then { } else builtNiriSettings);
  hasNiriSettings = effectiveNiriSettings != { };
  hasNiriConfig = niriConfig != null;
  niriPackage = lib.attrByPath [ "niri-unstable" ] null pkgs;
  rosePineCursorPkg = lib.attrByPath [ "rose-pine-cursor" ] null pkgs;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = rosePineCursorPkg != null;
            message = "desktop.compositor = \"niri\" requires the nixpkgs package 'rose-pine-cursor'.";
          }
        ];

        home.packages = lib.optionals (rosePineCursorPkg != null) [ rosePineCursorPkg ];

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
      (lib.mkIf hasNiriConfig {
        programs.niri.config = niriConfig;
      })
      (lib.mkIf (!hasNiriConfig && hasNiriSettings) {
        programs.niri.settings = effectiveNiriSettings;
      })
    ]
  );
}
