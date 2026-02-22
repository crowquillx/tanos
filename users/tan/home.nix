{ lib, vars ? { }, inputs, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  shell = get [ "desktop" "shell" ] "none";
  niriSource = get [ "desktop" "niri" "source" ] "naxdy";
  niriInput = if niriSource == "upstream" then inputs.niri-upstream else inputs.niri-naxdy;
  niriHmModule =
    let
      candidates = [
        (lib.attrByPath [ "homeModules" "niri" ] null niriInput)
        (lib.attrByPath [ "homeModules" "default" ] null niriInput)
        (lib.attrByPath [ "homeManagerModules" "niri" ] null niriInput)
        (lib.attrByPath [ "homeManagerModules" "default" ] null niriInput)
      ];
    in
    lib.findFirst (m: m != null) null candidates;
  dmsHmModule =
    let
      renamed = lib.attrByPath [ "dms" "homeModules" "dank-material-shell" ] null inputs;
      legacy = lib.attrByPath [ "dms" "homeModules" "dankMaterialShell" "default" ] null inputs;
    in
    if renamed != null then renamed else legacy;
  noctaliaHmModule = inputs.noctalia.homeModules.default or null;
in
{
  imports =
    [
      ../../modules/home/base/default.nix
      ../../modules/home/base/extra-packages.nix
      ../../modules/home/desktop/session-runtime.nix
      ../../modules/home/desktop/niri-user.nix
    ]
    ++ lib.optionals (desktopEnabled && compositor == "niri" && niriHmModule != null) [ niriHmModule ]
    ++ lib.optionals (shell == "dms" && dmsHmModule != null) [ dmsHmModule ]
    ++ lib.optionals (shell == "noctalia" && noctaliaHmModule != null) [ noctaliaHmModule ];

  assertions = [
    {
      assertion = !(desktopEnabled && compositor == "niri") || niriHmModule != null;
      message = ''
        Unable to resolve a Home Manager niri module from selected source "${niriSource}".
        Expected one of: homeModules.niri, homeModules.default, homeManagerModules.niri, homeManagerModules.default.
      '';
    }
  ];

  home.username = "tan";
  home.homeDirectory = "/home/tan";
}
