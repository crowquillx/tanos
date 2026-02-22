{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
in
{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    firefox
    alacritty
    fzf
    bat
    eza
  ];

  programs.git.enable = true;
  programs.bash.enable = true;

  xdg = {
    enable = true;
    userDirs.enable = true;
    # Avoid repeated activation failures when a previous backup file already exists.
    configFile."user-dirs.dirs".force = true;
  };

  gtk = lib.mkIf (get [ "desktop" "enable" ] true) {
    enable = true;
  };
}
