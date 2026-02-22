{ lib, options, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  niriSource = get [ "desktop" "niri" "source" ] "naxdy";
  niriOutputs = get [ "desktop" "niri" "outputs" ] { };
  niriBlurOverride = get [ "desktop" "niri" "blur" ] null;
  niriBlurDefaults =
    if niriSource == "upstream" then {
      on = true;
      radius = 5.0;
      noise = 0.03;
      brightness = 1.0;
      contrast = 1.0;
      saturation = 1.0;
    } else {
      on = true;
      radius = 7.5;
      noise = 0.054;
      brightness = 0.817;
      contrast = 1.3;
      saturation = 1.08;
    };
  niriBlur = if niriBlurOverride != null then niriBlurOverride else niriBlurDefaults;
  shell = get [ "desktop" "shell" ] "none";
  startupCommand = get [ "desktop" "shellStartupCommand" ] null;
  defaultShellStartupCommand =
    if shell == "dms" then "dms run --session"
    else if shell == "noctalia" then "noctalia-shell"
    else null;
  effectiveStartupCommand = if startupCommand != null then startupCommand else defaultShellStartupCommand;
  shellStartupEntries = lib.optionals (effectiveStartupCommand != null) [
    { command = [ "bash" "-lc" effectiveStartupCommand ]; }
  ];
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") (
    (
      lib.optionalAttrs (options ? programs.niri.settings) {
      # Home Manager-owned Niri config, with host-driven outputs/blur from variables.nix.
      programs.niri.settings =
        {
        prefer-no-csd = true;

        hotkey-overlay = {
          skip-at-startup = true;
        };

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        input = {
          keyboard = {
            xkb.layout = "us";
            repeat-delay = 250;
            repeat-rate = 50;
          };
          touchpad = {
            tap = true;
            tap-button-map = "left-right-middle";
          };
          mouse.accel-profile = "flat";
          mod-key = "Super";
          mod-key-nested = "Alt";
        };

        layout = {
          gaps = 25;
          background-color = "transparent";
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };
          border = {
            off = true;
            width = 4;
            active-color = "#707070";
            inactive-color = "#d0d0d0";
            urgent-color = "#cc4444";
          };
          focus-ring = {
            off = true;
            width = 1;
            active-color = "#808080";
            inactive-color = "#505050";
          };
          shadow = {
            softness = 30;
            spread = 5;
            offset = {
              x = 0;
              y = 5;
            };
            color = "#0007";
          };
          struts = { };
        };

        cursor = {
          xcursor-theme = "capitaine-cursors-light";
          xcursor-size = 24;
          hide-when-typing = true;
        };

        overview.zoom = 0.75;

        window-rules =
          (lib.optionals (niriSource == "naxdy") [
            # Naxdy-only blur values, host-configurable in desktop.niri.blur.
            { blur = niriBlur; }
          ])
          ++ [
            {
            geometry-corner-radius = 16;
            clip-to-geometry = true;
            }
            {
              matches = [
                { is-active = false; }
              ];
              opacity = 0.9;
            }
          ];

        environment = {
          XDG_CURRENT_DESKTOP = "niri";
          QT_QPA_PLATFORM = "wayland";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          QT_LOGGING_RULES = "quickshell.dbus.properties=false";
          QT_QPA_PLATFORMTHEME = "kde";
          QT_STYLE_OVERRIDE = "Darkly";
          ILLOGICAL_IMPULSE_VIRTUAL_ENV = "$HOME/.local/state/quickshell/.venv";
        };

        spawn-at-startup = [
          {
            command = [ "bash" "-c" "wl-paste --watch cliphist store &" ];
          }
          {
            command = [ "qs" "-c" "ii" ];
          }
        ] ++ shellStartupEntries;
      }
      // lib.optionalAttrs (niriOutputs != { }) {
        outputs = niriOutputs;
      };
    }
    )
    // lib.optionalAttrs (shell == "dms" && options ? programs.dank-material-shell.enable) {
      # If the shell HM module is available, default it on when selected.
      programs.dank-material-shell.enable = lib.mkDefault true;
      programs.dank-material-shell.systemd.enable = lib.mkDefault false;
    }
    // lib.optionalAttrs (shell == "noctalia" && options ? programs.noctalia-shell.enable) {
      # If the shell HM module is available, default it on when selected.
      programs.noctalia-shell.enable = lib.mkDefault true;
      programs.noctalia-shell.systemd.enable = lib.mkDefault false;
    }
    // lib.optionalAttrs (shell == "noctalia" && options ? services.noctalia-shell.enable) {
      services.noctalia-shell.enable = lib.mkDefault true;
    }
    // lib.optionalAttrs (niriSource != "naxdy" && niriBlurOverride != null) {
      warnings = [ "desktop.niri.blur is ignored unless desktop.niri.source = \"naxdy\"." ];
    }
  );
}
