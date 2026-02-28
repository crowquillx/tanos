{ ... }:
{
  imports =
    [
      ../../modules/home/base/default.nix
      ../../modules/home/base/extra-packages.nix
      ../../modules/home/base/tcli.nix
      ../../modules/home/terminals/kitty.nix
      ../../modules/home/theme/gtk.nix
      ../../modules/home/theme/qt.nix
      ../../modules/home/shell/zoxide.nix
      ../../modules/home/desktop/session-runtime.nix
      ../../modules/home/desktop/hyprland-user.nix
    ];

  home.username = "tan";
  home.homeDirectory = "/home/tan";
}
