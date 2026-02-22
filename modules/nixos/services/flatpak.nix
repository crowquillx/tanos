{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "flatpak" "enable" ] false;
in
{
  config = lib.mkIf enabled {
    services.flatpak.enable = true;

    # Keep remote setup compatible across nixpkgs revisions where
    # services.flatpak.remotes/update suboptions may not exist.
    system.activationScripts.tanosFlatpakFlathub = {
      text = ''
        if command -v flatpak >/dev/null 2>&1; then
          if ! flatpak --system remote-list | grep -q '^flathub$'; then
            flatpak --system remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
          fi
        fi
      '';
    };
  };
}
