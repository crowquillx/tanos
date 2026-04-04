{ lib, vars, leaf, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  startupBackend = get [ "desktop" "startup" "backend" ] "systemd";
  defaultStartupApps = [
    "wl-paste --watch cliphist store"
  ];
  startupApps = get [ "desktop" "startup" "apps" ] defaultStartupApps;
in
lib.optionals (startupBackend == "niri") (
  map (command: leaf "spawn-at-startup" [ "sh" "-lc" command ]) startupApps
)
