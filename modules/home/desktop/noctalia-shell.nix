{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  compositor = get [ "desktop" "compositor" ] "niri";
  noctaliaEnable = get [ "desktop" "noctalia" "enable" ] (desktopEnabled && compositor == "niri");
  lockEnable = get [ "desktop" "session" "lock" "enable" ] true;
  lockCommand = get [ "desktop" "session" "lock" "command" ] "loginctl lock-session";
  lockTimeout = get [ "desktop" "session" "lock" "idleSeconds" ] 600;
  screenOffTimeout = get [ "desktop" "session" "idle" "screenOffSeconds" ] (lockTimeout + 300);
  suspendTimeout = get [ "desktop" "session" "idle" "suspendSeconds" ] 1800;
  noctaliaSettings = get [ "desktop" "noctalia" "settings" ] { };
  managedIdleSettings = {
    general = {
      lockOnSuspend = true;
    };
    idle = {
      enabled = lockEnable;
      inherit lockCommand lockTimeout screenOffTimeout;
    } // lib.optionalAttrs (suspendTimeout != null) {
      inherit suspendTimeout;
    };
  };
in
{
  config = lib.mkIf (desktopEnabled && compositor == "niri" && noctaliaEnable) {
    programs.noctalia = {
      enable = true;
      systemd.enable = get [ "desktop" "noctalia" "systemd" "enable" ] true;
      settings = noctaliaSettings // managedIdleSettings;
      customPalettes =
        let
          palettes = get [ "desktop" "noctalia" "colors" ] { };
        in
        if palettes == { } then
          { }
        else
          { "default" = palettes; };
    };
  };
}
