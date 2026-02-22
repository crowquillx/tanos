{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  generatedHardwareFile = ../../.local/hardware-configuration-tandesk.nix;
in
{
  imports =
    [
      ../common/default.nix
      ./hardware-configuration.nix
    ]
    ++ lib.optionals (builtins.pathExists generatedHardwareFile) [ generatedHardwareFile ];

  networking.hostName = get [ "host" "name" ] "tandesk";

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
