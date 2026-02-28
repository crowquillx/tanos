{ lib, options, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "hyprland";
  hasHyprlandEnableOption = lib.hasAttrByPath [ "wayland" "windowManager" "hyprland" "enable" ] options;
  hasHyprlandExtraConfigOption = lib.hasAttrByPath [ "wayland" "windowManager" "hyprland" "extraConfig" ] options;
  hasIllogicalEnableOption = lib.hasAttrByPath [ "programs" "illogical-impulse" "enable" ] options;
in
{
  config = lib.mkIf (desktopEnabled && compositor == "hyprland") (
    lib.mkMerge [
      {
        home.sessionVariables = {
          XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland";
          XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
          NIXOS_OZONE_WL = lib.mkDefault "1";
          ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
        };
      }
      (lib.optionalAttrs hasHyprlandEnableOption {
        wayland.windowManager.hyprland.enable = lib.mkDefault true;
      })
      (lib.optionalAttrs hasHyprlandExtraConfigOption {
        # Illogical manages the actual files in ~/.config/hypr; this links HM Hyprland to that entrypoint.
        wayland.windowManager.hyprland.extraConfig = lib.mkDefault "source = ~/.config/hypr/hyprland.conf";
      })
      (lib.optionalAttrs hasIllogicalEnableOption {
        programs.illogical-impulse.enable = lib.mkDefault true;
      })
      (lib.optionalAttrs (!hasHyprlandEnableOption) {
        warnings = [ "Hyprland Home Manager option wayland.windowManager.hyprland.enable was not found; skipping user-level Hyprland enablement." ];
      })
      (lib.optionalAttrs (!hasIllogicalEnableOption) {
        warnings = [ "Illogical option programs.illogical-impulse.enable was not found; skipping Illogical enablement." ];
      })
    ]
  );
}
