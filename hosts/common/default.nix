{ lib, config, vars, inputs, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
  hyprlandHmModule = lib.attrByPath [ "hyprland" "homeManagerModules" "default" ] null inputs;
  illogicalHmModule = lib.attrByPath [ "illogical" "homeManagerModules" "default" ] null inputs;
in
{
  imports = [
    ./variables-schema.nix
    ../../modules/nixos/base/default.nix
    ../../modules/nixos/theme/stylix.nix
    ../../modules/nixos/hardware/graphics.nix
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/shells/fish-starship.nix
    ../../modules/nixos/services/audio.nix
    ../../modules/nixos/services/core.nix
    ../../modules/nixos/services/bluetooth.nix
    ../../modules/nixos/services/networking.nix
    ../../modules/nixos/services/portals.nix
    ../../modules/nixos/services/filemanager.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/nh.nix
    ../../modules/nixos/services/steam.nix
    ../../modules/nixos/services/virtualisation.nix
    ../../modules/nixos/services/keyring.nix
    ../../modules/nixos/security/sops.nix
    ../../modules/nixos/profiles/vm-guest.nix
    ../../modules/nixos/profiles/laptop.nix
  ];

  tanos.variables = vars;

  assertions = [
    {
      assertion =
        let
          compositor = get [ "desktop" "compositor" ] "hyprland";
        in
        compositor == "hyprland";
      message = "desktop.compositor must be set to \"hyprland\".";
    }
    {
      assertion =
        let
          dm = get [ "desktop" "displayManager" ] "auto";
        in
        builtins.elem dm [ "auto" "sddm" ];
      message = ''
        desktop.displayManager must be one of: auto, sddm.
      '';
    }
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit vars inputs; };
    sharedModules =
      lib.optionals (hyprlandHmModule != null) [ hyprlandHmModule ]
      ++ lib.optionals (illogicalHmModule != null) [ illogicalHmModule ];
    users.${primaryUser} = {
      imports = [ (import (../../users + "/${primaryUser}/home.nix")) ];
      home.username = lib.mkForce primaryUser;
      home.homeDirectory = lib.mkForce "/home/${primaryUser}";
      xdg.configHome = lib.mkForce "/home/${primaryUser}/.config";
    };
  };
}
