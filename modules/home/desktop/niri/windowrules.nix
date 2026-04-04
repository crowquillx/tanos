{ plain, leaf, flag, rgbaApps, ... }:
let
  equibopElectronMatch = {
    app-id = "^electron$";
    title = "^.*Discord.*$";
  };
in
[
  (plain "window-rule" [
    (leaf "match" { app-id = "^org\\.wezfurlong\\.wezterm$"; })
    (plain "default-column-width" [ ])
  ])

  (plain "window-rule" [
    (leaf "match" {
      app-id = "firefox$";
      title = "^Picture-in-Picture$";
    })
    (leaf "open-floating" true)
  ])

  (plain "window-rule" [
    (leaf "geometry-corner-radius" 20)
    (leaf "clip-to-geometry" true)
  ])

  (plain "window-rule" [
    (leaf "geometry-corner-radius" 12)
    (leaf "clip-to-geometry" true)
    (leaf "tiled-state" true)
    (leaf "draw-border-with-background" false)
  ])

  (plain "window-rule" [
    (leaf "match" { app-id = rgbaApps.terminals; })
    (leaf "match" { app-id = rgbaApps.fileManagers; })
    (leaf "match" { app-id = rgbaApps.chats; })
    (leaf "match" { app-id = rgbaApps.editors; })
    (leaf "match" equibopElectronMatch)
    (leaf "opacity" 0.90)
    (leaf "draw-border-with-background" false)
    (plain "background-effect" [
      (leaf "blur" true)
      (leaf "xray" false)
    ])
  ])

  (plain "window-rule" [
    (leaf "match" { app-id = rgbaApps.terminals; is-focused = true; })
    (leaf "match" { app-id = rgbaApps.fileManagers; is-focused = true; })
    (leaf "match" { app-id = rgbaApps.chats; is-focused = true; })
    (leaf "match" { app-id = rgbaApps.editors; is-focused = true; })
    (leaf "match" (equibopElectronMatch // { is-focused = true; }))
    (leaf "opacity" 0.96)
  ])

  (plain "window-rule" [
    (leaf "match" { app-id = "^(Awakened PoE Trade|awakened-poe-trade)$"; })
    (leaf "open-floating" true)
    (leaf "draw-border-with-background" false)
    (plain "focus-ring" [
      (flag "off")
    ])
    (plain "border" [
      (flag "off")
    ])
    (plain "shadow" [
      (flag "off")
    ])
  ])

  (plain "window-rule" [
    (leaf "match" { app-id = "^thunar$"; })
    (leaf "opacity" 0.95)
    (leaf "open-floating" true)
    (leaf "min-width" 450)
    (leaf "min-height" 225)
  ])

  (plain "window-rule" [
    (leaf "match" equibopElectronMatch)
    (leaf "open-on-output" "DP-1")
    (leaf "open-maximized" true)
  ])

  (plain "window-rule" [
    (leaf "match" { app-id = "^spotify$"; })
    (leaf "open-on-output" "DP-2")
    (leaf "open-maximized" true)
  ])

]
