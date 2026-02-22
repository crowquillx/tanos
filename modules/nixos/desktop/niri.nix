{ lib, pkgs, config, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriSource = get [ "desktop" "niri" "source" ] "naxdy";
  niriPkg =
    if niriSource == "upstream"
    then (inputs.niri-upstream.packages.${pkgs.system}.default or pkgs.niri)
    else (inputs.niri-naxdy.packages.${pkgs.system}.default or pkgs.niri);
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") {
    programs.niri = {
      enable = true;
      package = niriPkg;
    };

    services.displayManager.sessionPackages = [ niriPkg ];
  };
}
