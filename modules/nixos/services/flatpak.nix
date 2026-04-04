{ lib, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "flatpak" "enable" ] false;
  packageRefs = get [ "features" "flatpak" "packages" ] [ ];
  desiredRefsFile = builtins.toFile "tanos-flatpak-packages" (
    lib.concatStringsSep "\n" packageRefs
    + lib.optionalString (packageRefs != [ ]) "\n"
  );
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = builtins.all (ref: lib.isString ref && ref != "") packageRefs;
          message = "features.flatpak.packages must be a list of non-empty Flatpak app IDs.";
        }
        {
          assertion = enabled || packageRefs == [ ];
          message = "features.flatpak.packages requires features.flatpak.enable = true.";
        }
      ];
    }
    (lib.mkIf enabled {
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

      system.activationScripts.tanosFlatpakPackages = {
        deps = [ "tanosFlatpakFlathub" ];
        text = ''
          if ! command -v flatpak >/dev/null 2>&1; then
            exit 0
          fi

          state_dir=/var/lib/tanos
          state_file="$state_dir/flatpak-managed.list"
          desired_file="${desiredRefsFile}"

          install -d -m 0755 "$state_dir"

          while IFS= read -r ref; do
            [ -n "$ref" ] || continue

            if ! flatpak --system info "$ref" >/dev/null 2>&1; then
              flatpak --system install -y --noninteractive flathub "$ref"
            fi
          done < "$desired_file"

          if [ -f "$state_file" ]; then
            while IFS= read -r ref; do
              [ -n "$ref" ] || continue

              if ! grep -Fxq "$ref" "$desired_file"; then
                flatpak --system uninstall -y --noninteractive "$ref" || true
              fi
            done < "$state_file"
          fi

          install -m 0644 "$desired_file" "$state_file"
        '';
      };
    })
  ];
}
