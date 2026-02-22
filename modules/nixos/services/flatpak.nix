{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "flatpak" "enable" ] false;
  uninstallUnmanaged = get [ "features" "flatpak" "uninstallUnmanaged" ] false;
in
{
  config = lib.mkIf enabled {
    services.flatpak = {
      enable = true;
      update.onActivation = true;
      uninstallUnmanaged = uninstallUnmanaged;
      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
      ];
    };
  };
}
