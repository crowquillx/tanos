{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "portals" "enable" ] true;
in
{
  config = lib.mkIf enabled {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
      config = {
        common.default = [ "gtk" ];
        niri.default = [ "gtk" ];
        niri."org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        kde.default = [ "kde" "gtk" ];
        KDE.default = [ "kde" "gtk" ];
        plasma.default = [ "kde" "gtk" ];
      };
      configPackages = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
    };
  };
}
