{ lib, config, vars, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
in
{
  imports = [
    ./variables-schema.nix
    ../../modules/nixos/base/default.nix
    ../../modules/nixos/hardware/graphics.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/dms-greeter.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/services/audio.nix
    ../../modules/nixos/services/bluetooth.nix
    ../../modules/nixos/services/networking.nix
    ../../modules/nixos/services/portals.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/keyring.nix
    ../../modules/nixos/security/sops.nix
    ../../modules/nixos/shells/dms.nix
    ../../modules/nixos/shells/noctalia.nix
    ../../modules/nixos/profiles/vm-guest.nix
    ../../modules/nixos/profiles/laptop.nix
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
      assertion =
        let
          shell = get [ "desktop" "shell" ] "none";
          dm = get [ "desktop" "displayManager" ] "auto";
          effectiveDm =
            if dm == "auto"
            then if shell == "dms" then "dms-greeter" else "sddm"
            else dm;
        in
        builtins.elem dm [ "auto" "sddm" "dms-greeter" ]
        && (effectiveDm != "dms-greeter" || shell == "dms");
      message = ''
        desktop.displayManager must be one of: auto, sddm, dms-greeter.
        dms-greeter is only supported when desktop.shell = "dms".
      '';
    }
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit vars inputs; };
    users.${primaryUser} = import (../../users + "/${primaryUser}/home.nix");
  };
}
