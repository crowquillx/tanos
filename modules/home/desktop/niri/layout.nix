{ plain, leaf, flag, ... }:
[
  (plain "layout" [
    (leaf "gaps" 12)
    (leaf "center-focused-column" "never")

    (plain "preset-column-widths" [
      (leaf "proportion" 0.33333)
      (leaf "proportion" 0.5)
      (leaf "proportion" 0.66667)
    ])

    (plain "default-column-width" [
      (leaf "proportion" 0.5)
    ])

    (plain "focus-ring" [
      (leaf "width" 2)
      (leaf "active-color" "#ebbcba")
      (leaf "inactive-color" "#191724")
      (leaf "urgent-color" "#eb6f92")
    ])

    (plain "border" [
      (flag "off")
      (leaf "width" 2)
      (leaf "active-color" "#ebbcba")
      (leaf "inactive-color" "#191724")
      (leaf "urgent-color" "#eb6f92")
    ])

    (plain "shadow" [
      (leaf "softness" 30)
      (leaf "spread" 5)
      (leaf "offset" { x = 0; y = 5; })
      (leaf "color" "#19172470")
    ])

    (plain "tab-indicator" [
      (leaf "active-color" "#ebbcba")
      (leaf "inactive-color" "#ce2b24")
      (leaf "urgent-color" "#eb6f92")
    ])

    (plain "insert-hint" [
      (leaf "color" "#ebbcba80")
    ])
  ])
]