{ lib, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  enabled = get [ "features" "terminals" "kitty" "enable" ] true;
in
{
  config = lib.mkIf enabled {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        window_padding_width = 10;
      };
    };
  };
}
