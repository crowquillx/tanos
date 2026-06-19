{
  lib,
  vars,
  plain,
  leaf,
  ...
}:
let
  blur = lib.attrByPath [ "desktop" "niri" "blur" ] { } vars;
  enabled = blur.enable or true;
  passes = blur.passes or 2;
  offset = blur.offset or 3.0;
  noise = blur.noise or 0.03;
  saturation = blur.saturation or 1.0;
in
if !enabled then
  [ ]
else
  [
    (plain "blur" [
      (leaf "passes" passes)
      (leaf "offset" offset)
      (leaf "noise" noise)
      (leaf "saturation" saturation)
    ])
  ]
