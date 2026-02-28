{ lib, pkgs, config, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "hyprland";
  hyprlandPkg = lib.attrByPath [ "hyprland" "packages" pkgs.stdenv.hostPlatform.system "hyprland" ] pkgs.hyprland inputs;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "hyprland") {
    programs.hyprland = {
      enable = true;
      package = hyprlandPkg;
    };

    services.displayManager.sessionPackages = [ hyprlandPkg ];

    nix.settings = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
}
