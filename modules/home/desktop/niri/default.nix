{ lib, inputs, vars, ... }:
let
  get = path: default: lib.attrByPath path default vars;
  useWip = get [ "desktop" "niri" "useWip" ] false;
  niriInput = if useWip then inputs."niri-wip" else inputs.niri;
  inherit (niriInput.lib.kdl) node plain leaf flag;

  optionalNode = cond: value: if cond then value else null;
  normalize = values: builtins.filter (value: value != null) (lib.flatten values);

  formatMode = mode:
    if builtins.isAttrs mode then
      let
        base = "${toString mode.width}x${toString mode.height}";
        refresh = mode.refresh or null;
      in
      if refresh == null then base else "${base}@${toString refresh}"
    else
      mode;

  formatTransform = transform:
    if builtins.isAttrs transform then
      let
        rotation = toString (transform.rotation or 0);
        flipped = transform.flipped or false;
        base = if rotation == "0" then "normal" else rotation;
      in
      if flipped then
        if rotation == "0" then "flipped" else "flipped-${rotation}"
      else
        base
    else
      transform;

  mkOutput = name: output:
    node "output" name (normalize [
      (optionalNode ((output.enable or true) == false) (flag "off"))
      (optionalNode (output ? mode && output.mode != null) (leaf "mode" (formatMode output.mode)))
      (optionalNode (output ? scale && output.scale != null) (leaf "scale" output.scale))
      (optionalNode (output ? transform && output.transform != null) (leaf "transform" (formatTransform output.transform)))
      (optionalNode (output ? position && output.position != null) (leaf "position" output.position))
      (optionalNode (output ? variableRefreshRate && output.variableRefreshRate != null && output.variableRefreshRate != false) (
        if output.variableRefreshRate == "on-demand" then
          leaf "variable-refresh-rate" { on-demand = true; }
        else
          leaf "variable-refresh-rate" output.variableRefreshRate
      ))
      (optionalNode (output.focusAtStartup or false) (flag "focus-at-startup"))
    ]);

  rgbaApps = {
    terminals = "^org\\.wezfurlong\\.wezterm$|^com\\.mitchellh\\.ghostty$|^ghostty$|^kitty$|^Alacritty$|^alacritty$|^foot$";
    fileManagers = "^thunar$|^org\\.kde\\.dolphin$|^dolphin$|^org\\.gnome\\.Nautilus$|^nautilus$|^nemo$|^pcmanfm$";
    chats = "^equibop$|^vesktop$|^dev\\.vencord\\.Vesktop$|^discord$|^com\\.discordapp\\.Discord$|^org\\.telegram\\.desktop$|^telegram-desktop$|^element$|^im\\.riot\\.Riot$|^comet$|^org\\.gnome\\.Fractal$|^fractal$";
    editors = "^code$|^code-url-handler$|^com\\.visualstudio\\.code$|^code-oss$|^codium$|^vscodium$|^cursor$|^zed$|^dev\\.zed\\.Zed$|^t3-code$|^T3 Code.*$|^windsurf$|^jetbrains-.*$|^android-studio$|^neovide$|^emacs$|^micro$";
  };

  context = {
    inherit lib vars inputs useWip node plain leaf flag optionalNode normalize mkOutput rgbaApps;
  };
in
normalize [
  (import ./input.nix context)
  (import ./outputs.nix context)
  (import ./layout.nix context)
  (import ./cursor.nix context)
  (import ./blur.nix context)
  (import ./noctalia.nix context)
  (import ./windowrules.nix context)
  (import ./config-fragments.nix context)
  (import ./binds.nix context)
]