{
  lib,
  vars,
  plain,
  leaf,
  ...
}:
let
  get = path: default: lib.attrByPath path default vars;
  noctaliaSystemdEnabled = get [ "desktop" "noctalia" "systemd" "enable" ] true;
  noctaliaCommand = get [ "desktop" "noctalia" "command" ] "noctalia-shell";
in
lib.optionals (!noctaliaSystemdEnabled) [
  (leaf "spawn-at-startup" [ noctaliaCommand ])

  (plain "layer-rule" [
    (leaf "match" { namespace = "^noctalia-backdrop"; })
    (leaf "place-within-backdrop" true)
  ])

  (plain "layer-rule" [
    (leaf "match" { namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"; })
    (plain "background-effect" [
      (leaf "xray" false)
    ])
  ])

  (plain "recent-windows" [
    (plain "highlight" [
      (leaf "active-color" "#ebbcba")
      (leaf "urgent-color" "#eb6f92")
    ])
  ])
]
