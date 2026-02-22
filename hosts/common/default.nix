{ lib, config, vars, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
in
{
  imports = [
    ./variables-schema.nix
    ../../modules/nixos/base/default.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/shells/dms.nix
    ../../modules/nixos/shells/noctalia.nix
    ../../modules/nixos/services/audio.nix
    ../../modules/nixos/services/bluetooth.nix
    ../../modules/nixos/services/networking.nix
    ../../modules/nixos/services/portals.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/security/sops.nix
    ../../modules/nixos/profiles/vm-guest.nix
    ../../modules/nixos/profiles/gaming.nix
  ];

  tanos.variables = vars;

  assertions = [
    {
      assertion =
        let
          shell = get [ "desktop" "shell" ] "none";
          compositor = get [ "desktop" "compositor" ] "niri";
        in
        shell == "none" || compositor == "niri";
      message = "A desktop shell requires desktop.compositor = \"niri\".";
    }
    {
      assertion = get [ "desktop" "displayManager" ] "sddm" == "sddm";
      message = "This repo currently supports only desktop.displayManager = \"sddm\".";
    }
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit vars; };
    users.${primaryUser} = import (../../users + "/${primaryUser}/home.nix");
  };
}
