{
  lib,
  pkgs,
  config,
  vars,
  inputs,
  combined,
  ...
}:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
  noctaliaHmModule = lib.attrByPath [ "noctalia" "homeModules" "default" ] null inputs;
  hmBackupCommand = pkgs.writeShellScript "home-manager-backup" ''
    set -eu

    target_path="$1"
    timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
    backup_path="${"$"}{target_path}.hm-backup-${"$"}timestamp"

    while [ -e "$backup_path" ]; do
      timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)-$RANDOM"
      backup_path="${"$"}{target_path}.hm-backup-${"$"}timestamp"
    done

    exec ${pkgs.coreutils}/bin/mv "$target_path" "$backup_path"
  '';
in
{
  imports = [
    ./variables-schema.nix
  ]
  ++ combined.nixosModules;

  tanos.variables = vars;

  assertions = [
    {
      assertion =
        let
          compositor = get [ "desktop" "compositor" ] "niri";
        in
        builtins.elem compositor [
          "niri"
          "plasma"
        ];
      message = "desktop.compositor must be one of: niri, plasma.";
    }
    {
      assertion =
        let
          extraCompositors = get [ "desktop" "extraCompositors" ] [ ];
        in
        builtins.all (
          c:
          builtins.elem c [
            "niri"
            "plasma"
          ]
        ) extraCompositors;
      message = "desktop.extraCompositors may only include: niri, plasma.";
    }
    {
      assertion =
        let
          dm = get [ "desktop" "displayManager" ] "auto";
        in
        builtins.elem dm [
          "auto"
          "sddm"
        ];
      message = ''
        desktop.displayManager must be one of: auto, sddm.
      '';
    }
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupCommand = hmBackupCommand;
    extraSpecialArgs = { inherit vars inputs combined; };
    sharedModules = lib.optionals (noctaliaHmModule != null) [ noctaliaHmModule ];
    users.${primaryUser} = {
      imports = [ ../../users/${primaryUser}/home.nix ];
      home.username = lib.mkForce primaryUser;
      home.homeDirectory = lib.mkForce "/home/${primaryUser}";
      xdg.configHome = lib.mkForce "/home/${primaryUser}/.config";
    };
  };
}
