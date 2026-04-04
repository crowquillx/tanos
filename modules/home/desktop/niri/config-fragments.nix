{ plain, leaf, flag, ... }:
[
  (plain "hotkey-overlay" [ ])
  (flag "prefer-no-csd")
  (leaf "screenshot-path" "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png")
  (plain "animations" [ ])

  (plain "debug" [
    (flag "honor-xdg-activation-with-invalid-serial")
  ])
]