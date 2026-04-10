{ combined, config, ... }:
{
  imports = combined.homeModules;

  home.username = "tan";
  home.homeDirectory = "/home/tan";

  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/tanos/wallpapers";
}
