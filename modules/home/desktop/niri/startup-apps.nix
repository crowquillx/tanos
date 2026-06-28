{ lib, vars, leaf, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  startupBackend = get [ "desktop" "startup" "backend" ] "systemd";
  defaultStartupApps = [
    "wl-paste --watch cliphist store"
  ];
  startupApps = get [ "desktop" "startup" "apps" ] defaultStartupApps;
  chatClient = get [ "features" "chat" "client" ] "none";
  chatStartupEnable = get [ "features" "chat" "startup" "enable" ] (chatClient != "none");
  chatCommands =
    if chatClient == "discord" then
      [ "sleep 5 && discord" ]
    else if chatClient == "equibop" then
      [ "sleep 5 && equibop" ]
    else
      [ ];
  effectiveStartupApps =
    startupApps
    ++ lib.optionals chatStartupEnable chatCommands;
in
lib.optionals (startupBackend == "niri") (
  map (command: leaf "spawn-at-startup" [ "sh" "-lc" command ]) effectiveStartupApps
)
