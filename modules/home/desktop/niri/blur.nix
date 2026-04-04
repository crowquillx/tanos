{ lib, vars, useWip, plain, leaf, ... }:
let
  blur = lib.attrByPath [ "desktop" "niri" "blur" ] { } vars;
  enabled = blur.enable or true;
in
if !useWip || !enabled then
  [ ]
else
  [
    (plain "blur" [
      (leaf "passes" (blur.passes or 3))
      (leaf "offset" (blur.offset or 3.0))
      (leaf "noise" (blur.noise or 0.03))
      (leaf "saturation" (blur.saturation or 1.0))
    ])
  ]