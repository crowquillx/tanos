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
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri") (
    (
      {
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
            {
              matches = [
                { app-id = "^zen$"; }
                { app-id = "^zen-browser$"; }
              ];
              opacity = 1.0;
            }
            {
              matches = [
                { app-id = "^org\\.quickshell"; }
              ];
              opacity = 1.0;
            }
            {
              matches = [
                { is-active = true; app-id = "^ghostty$"; }
                { is-active = true; app-id = "^kitty$"; }
                { is-active = true; app-id = "^foot$"; }
                { is-active = true; app-id = "^footclient$"; }
                { is-active = true; app-id = "^Alacritty$"; }
                { is-active = true; app-id = "^org\\.wezfurlong\\.wezterm$"; }
                { is-active = true; app-id = "^konsole$"; }
                { is-active = true; app-id = "^org\\.kde\\.konsole$"; }
                { is-active = true; app-id = "^com\\.mitchellh\\.ghostty$"; }
              ];
              opacity = 0.95;
            }
            {
              matches = [
                { app-id = "^foot$"; }
                { app-id = "^footclient$"; }
              ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^spotify$"; } ];
              open-on-output = "DP-2";
              open-maximized = true;
            }
            {
              matches = [ { app-id = "^vesktop$"; } ];
              open-on-output = "DP-1";
              open-maximized = true;
            }
            {
              matches = [ { app-id = "^equibop$"; } ];
              open-on-output = "DP-1";
              open-maximized = true;
            }
            {
              matches = [ { title = "^Wayland to X Recording bridge - Xwayland Video Bridge$"; } ];
              open-floating = true;
              min-width = 1;
              max-width = 1;
              min-height = 1;
              max-height = 1;
            }
            {
              matches = [ { app-id = "^org\\.mozilla\\.firefox$"; } ];
              default-column-width = { proportion = 0.66667; };
            }
            {
              matches = [ { app-id = "^obsidian$"; } ];
              default-column-width = { fixed = 1000; };
            }
            {
              matches = [
                { app-id = "^blender$"; }
                { app-id = "^gimp"; }
              ];
              default-column-width = { fixed = 1200; };
            }
            {
              matches = [ { app-id = "^com\\.obsproject\\.Studio$"; } ];
              min-width = 876;
            }
            {
              matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
              default-column-width = { };
            }
          ];

        animations = {
          workspace-switch.kind.spring = {
            damping-ratio = 0.78;
            stiffness = 600;
            epsilon = 0.0001;
          };
          window-open.kind.spring = {
            damping-ratio = 0.82;
            stiffness = 500;
            epsilon = 0.0001;
          };
          window-close.kind.spring = {
            damping-ratio = 0.88;
            stiffness = 900;
            epsilon = 0.0001;
          };
          horizontal-view-movement.kind.spring = {
            damping-ratio = 0.80;
            stiffness = 550;
            epsilon = 0.0001;
          };
          window-movement.kind.spring = {
            damping-ratio = 0.85;
            stiffness = 650;
            epsilon = 0.0001;
          };
          window-resize.kind.spring = {
            damping-ratio = 0.88;
            stiffness = 700;
            epsilon = 0.0001;
          };
          config-notification-open-close.kind.spring = {
            damping-ratio = 0.90;
            stiffness = 800;
            epsilon = 0.0001;
          };
          screenshot-ui-open.kind.spring = {
            damping-ratio = 0.85;
            stiffness = 750;
            epsilon = 0.0001;
          };
        };

        environment = {
          XDG_CURRENT_DESKTOP = "niri";
          QT_QPA_PLATFORM = "wayland";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          QT_LOGGING_RULES = "quickshell.dbus.properties=false";
          ILLOGICAL_IMPULSE_VIRTUAL_ENV = "$HOME/.local/state/quickshell/.venv";
        };

        binds = {
          "Mod+Tab" = {
            repeat = false;
            action.toggle-overview = [ ];
          };
          "Mod+Shift+E".action.quit = [ ];
          "Mod+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = [ ];
          };
          "Alt+Tab".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "altSwitcher" "next" ];
          "Alt+Shift+Tab".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "altSwitcher" "previous" ];
          "Super+G".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "overlay" "toggle" ];
          "Mod+Space" = {
            repeat = false;
            action.toggle-overview = [ ];
          };
          "Mod+V".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "clipboard" "toggle" ];
          "Mod+L" = {
            allow-when-locked = true;
            action.spawn = [ "qs" "-c" "ii" "ipc" "call" "lock" "activate" ];
          };
          "Mod+Shift+S".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "region" "screenshot" ];
          "Mod+Shift+X".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "region" "ocr" ];
          "Mod+Shift+A".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "region" "search" ];
          "Ctrl+Alt+T".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "wallpaperSelector" "toggle" ];
          "Mod+Comma".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "settings" "open" ];
          "Mod+Slash".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "cheatsheet" "toggle" ];
          "Mod+Shift+W".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "panelFamily" "cycle" ];
          "MouseForward".action.spawn = [ "equibop" "--toggle-mic" ];
          "Mod+T".action.spawn = [ "bash" "-c" "$HOME/.config/quickshell/ii/scripts/launch-terminal.sh" ];
          "Mod+Return".action.spawn = [ "bash" "-c" "$HOME/.config/quickshell/ii/scripts/launch-terminal.sh" ];
          "Super+E".action.spawn = [ "dolphin" ];
          "Mod+Q" = {
            repeat = false;
            action.close-window = [ ];
          };
          "Mod+D".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "overview" "toggle" ];
          "Mod+F".action.maximize-column = [ ];
          "Mod+Shift+F".action.fullscreen-window = [ ];
          "Mod+A".action.toggle-window-floating = [ ];
          "Mod+Left".action.focus-column-left = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+Down".action.focus-window-down = [ ];
          "Mod+H".action.focus-column-left = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+Shift+Left".action.move-column-left = [ ];
          "Mod+Shift+Right".action.move-column-right = [ ];
          "Mod+Shift+Up".action.move-window-up = [ ];
          "Mod+Shift+Down".action.move-window-down = [ ];
          "Mod+Shift+H".action.move-column-left = [ ];
          "Mod+Shift+J".action.move-window-down = [ ];
          "Mod+Shift+K".action.move-window-up = [ ];
          "Mod+Shift+L".action.move-column-right = [ ];
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Print".action.screenshot = [ ];
          "Ctrl+Print".action.screenshot-screen = [ ];
          "Alt+Print".action.screenshot-window = [ ];
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [ "qs" "-c" "ii" "ipc" "call" "audio" "volumeUp" ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = [ "qs" "-c" "ii" "ipc" "call" "audio" "volumeDown" ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [ "qs" "-c" "ii" "ipc" "call" "audio" "mute" ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = [ "qs" "-c" "ii" "ipc" "call" "audio" "micMute" ];
          };
          "Ctrl+Mod+Space".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "mpris" "playPause" ];
          "Mod+Alt+N".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "mpris" "next" ];
          "Mod+Alt+P".action.spawn = [ "qs" "-c" "ii" "ipc" "call" "mpris" "previous" ];
          "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "5%+" ];
          "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "5%-" ];
          "Mod+Y".action.spawn = [ "bash" "-c" "pgrep footclient && pkill footclient || footclient" ];
          "Mod+Z".action.spawn = [ "zen-browser" ];
          "Mod+W".action.toggle-column-tabbed-display = [ ];
          "Mod+C".action.center-column = [ ];
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
          "Mod+O".action.toggle-overview = [ ];
          "Mod+Grave".action.toggle-overview = [ ];
          "Mod+U".action.focus-workspace-down = [ ];
          "Mod+I".action.focus-workspace-up = [ ];
          "Mod+Ctrl+Down".action.focus-workspace-down = [ ];
          "Mod+Ctrl+Up".action.focus-workspace-up = [ ];
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";
          "Mod+Ctrl+Return".action.toggle-window-floating = [ ];
          "Mod+Shift+Return".action.switch-focus-between-floating-and-tiling = [ ];
          "Mod+Shift+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
          "Ctrl+Alt+Delete".action.quit = [ ];
          "Mod+Shift+P".action.power-off-monitors = [ ];
        };
        layer-rules = [
          {
            matches = [ { namespace = "^quickshell:iiBackdrop$"; } ];
            place-within-backdrop = true;
            opacity = 1.0;
          }
          {
            matches = [ { namespace = "^quickshell:wBackdrop$"; } ];
            place-within-backdrop = true;
            opacity = 1.0;
          }
        ];
      };
      }
      // lib.optionalAttrs (niriOutputs != { }) {
        programs.niri.settings.outputs = niriOutputs;
      }
    )
    // lib.optionalAttrs (shell == "dms" && lib.hasAttrByPath [ "programs" "dank-material-shell" "enable" ] options) {
      # If the shell HM module is available, default it on when selected.
      programs."dank-material-shell".enable = lib.mkDefault true;
      programs."dank-material-shell".systemd.enable = lib.mkDefault false;
    }
    // lib.optionalAttrs (shell == "noctalia" && lib.hasAttrByPath [ "programs" "noctalia-shell" "enable" ] options) {
      # If the shell HM module is available, default it on when selected.
      programs."noctalia-shell".enable = lib.mkDefault true;
      programs."noctalia-shell".systemd.enable = lib.mkDefault false;
    }
    // lib.optionalAttrs (shell == "noctalia" && lib.hasAttrByPath [ "services" "noctalia-shell" "enable" ] options) {
      services."noctalia-shell".enable = lib.mkDefault true;
    }
    // lib.optionalAttrs (niriSource != "naxdy" && niriBlurOverride != null) {
      warnings = [ "desktop.niri.blur is ignored unless desktop.niri.source = \"naxdy\"." ];
    }
  );
}
