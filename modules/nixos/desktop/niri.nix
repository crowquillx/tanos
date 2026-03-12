{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriPackage = lib.attrByPath [ "niri-unstable" ] null pkgs;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") {
    assertions = [
      {
        assertion = niriPackage != null;
        message = "pkgs.niri-unstable is unavailable. Ensure inputs.niri.overlays.niri is applied before enabling the Niri desktop module.";
      }
    ];

    niri-flake.cache.enable = true;

    programs.niri = {
      enable = true;
      package = niriPackage;
    };
  };
}
