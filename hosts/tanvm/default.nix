{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
in
{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = get [ "host" "name" ] "tanvm";

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
