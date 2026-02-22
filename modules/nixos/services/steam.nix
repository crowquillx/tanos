{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "gaming" "enable" ] false;
  gamescopeSessionEnable = get [ "features" "gaming" "steam" "gamescopeSession" "enable" ] false;
  remotePlayOpenFirewall = get [ "features" "gaming" "steam" "remotePlay" "openFirewall" ] true;
  dedicatedServerOpenFirewall = get [ "features" "gaming" "steam" "dedicatedServer" "openFirewall" ] true;
  localTransfersOpenFirewall = get [ "features" "gaming" "steam" "localNetworkGameTransfers" "openFirewall" ] true;
in
{
  config = lib.mkIf enabled {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = gamescopeSessionEnable;
      remotePlay.openFirewall = remotePlayOpenFirewall;
      dedicatedServer.openFirewall = dedicatedServerOpenFirewall;
      localNetworkGameTransfers.openFirewall = localTransfersOpenFirewall;
    };
  };
}
