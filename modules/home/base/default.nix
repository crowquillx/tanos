{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
in
{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages =
    (with pkgs; [
      # General user tooling should be HM-managed.
      firefox
      alacritty
      foot
      fuzzel
      waybar
      wl-clipboard
      cliphist
      pavucontrol
      brightnessctl
      playerctl
      grim
      slurp
      networkmanagerapplet
      fzf
      bat
      eza
      jq
      ripgrep
      fd
      unzip
      zip
      vim
      neovim
      htop
      fastfetch
      wget
      curl
    ])
    ++ lib.optionals (get [ "desktop" "enable" ] true) (with pkgs; [
      # Desktop helpers commonly used by shell overlays.
      libnotify
    ]);

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
