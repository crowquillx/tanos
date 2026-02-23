{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriPkg = pkgs.niri-unstable;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") {
    programs.niri = {
      enable = true;
      package = niriPkg;
    };

    services.displayManager.sessionPackages = [ niriPkg ];

    nix.settings = {
      extra-substituters = [ "https://niri.cachix.org" ];
      extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    };
  };
}
