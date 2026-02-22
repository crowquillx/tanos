{ lib, vars ? { }, inputs, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  shell = get [ "desktop" "shell" ] "none";
  dmsHmModule = inputs.dms.homeModules.dankMaterialShell.default or null;
  noctaliaHmModule = inputs.noctalia.homeModules.default or null;
in
{
  imports =
    [
      ../../modules/home/base/default.nix
      ../../modules/home/base/extra-packages.nix
      ../../modules/home/desktop/niri-user.nix
    ]
    ++ lib.optionals (shell == "dms" && dmsHmModule != null) [ dmsHmModule ]
    ++ lib.optionals (shell == "noctalia" && noctaliaHmModule != null) [ noctaliaHmModule ];

  home.username = "tan";
  home.homeDirectory = "/home/tan";
}
