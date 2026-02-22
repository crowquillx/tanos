{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  nmEnabled = get [ "features" "networking" "networkmanager" "enable" ] true;
in
{
  config = lib.mkIf nmEnabled {
    networking.networkmanager.enable = true;
    environment.systemPackages = [ pkgs.networkmanagerapplet ];
  };
}
