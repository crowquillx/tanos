{ combined, ... }:
{
  imports = combined.homeModules;

  home.username = "tan";
  home.homeDirectory = "/home/tan";

  home.file."Pictures/Wallpapers".source = ../../wallpapers;
}
