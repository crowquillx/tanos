{ lib, config, ... }:
let
  cfg = config.tanos.variables.features.localsend;
in
{
  config = lib.mkIf cfg.openFirewall {
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];
  };
}
