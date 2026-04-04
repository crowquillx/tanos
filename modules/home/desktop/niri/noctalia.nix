{ lib, vars, plain, leaf, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  noctaliaSystemdEnabled = get [ "desktop" "noctalia" "systemd" "enable" ] true;
in
lib.optionals (!noctaliaSystemdEnabled) [
  (leaf "spawn-at-startup" [ "noctalia-shell" ])

  (plain "layer-rule" [
    (leaf "match" { namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; })
    (plain "background-effect" [
      (leaf "xray" false)
    ])
  ])

  (plain "layer-rule" [
    (leaf "match" { namespace = "^noctalia-overview*"; })
    (leaf "place-within-backdrop" true)
  ])

  (plain "recent-windows" [
    (plain "highlight" [
      (leaf "active-color" "#ebbcba")
      (leaf "urgent-color" "#eb6f92")
    ])
  ])
]
