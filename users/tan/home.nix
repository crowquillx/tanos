{ ... }:
{
  imports = [
    ../../modules/home/base/default.nix
    ../../modules/home/desktop/niri-user.nix
  ];

  home.username = "tan";
  home.homeDirectory = "/home/tan";
}
