{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "gaming" "enable" ] false;
  gamescopeSessionEnable = get [ "features" "gaming" "steam" "gamescopeSession" "enable" ] false;
  remotePlayOpenFirewall = get [ "features" "gaming" "steam" "remotePlay" "openFirewall" ] true;
  dedicatedServerOpenFirewall = get [ "features" "gaming" "steam" "dedicatedServer" "openFirewall" ] true;
  localTransfersOpenFirewall = get [ "features" "gaming" "steam" "localNetworkGameTransfers" "openFirewall" ] true;
  lutrisPkg = if pkgs ? lutris then pkgs.lutris else null;
  heroicPkg = if pkgs ? heroic then pkgs.heroic else null;
  protonPlusPkg =
    if pkgs ? protonplus then pkgs.protonplus else if pkgs ? "protonup-qt" then pkgs."protonup-qt" else null;
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !enabled || lutrisPkg != null;
          message = "features.gaming.enable is true, but nixpkgs package 'lutris' could not be resolved.";
        }
        {
          assertion = !enabled || heroicPkg != null;
          message = "features.gaming.enable is true, but nixpkgs package 'heroic' could not be resolved.";
        }
        {
          assertion = !enabled || protonPlusPkg != null;
          message = "features.gaming.enable is true, but neither 'protonplus' nor fallback 'protonup-qt' could be resolved.";
        }
      ];
    }
    (lib.mkIf enabled {
      programs.steam = {
        enable = true;
        gamescopeSession.enable = gamescopeSessionEnable;
        remotePlay.openFirewall = remotePlayOpenFirewall;
        dedicatedServer.openFirewall = dedicatedServerOpenFirewall;
        localNetworkGameTransfers.openFirewall = localTransfersOpenFirewall;
      };

      environment.systemPackages = [
        lutrisPkg
        heroicPkg
        protonPlusPkg
      ];
    })
  ];
}
