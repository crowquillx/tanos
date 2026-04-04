{ combined, config, ... }:
{
  imports = combined.homeModules;

  home.username = "tan";
  home.homeDirectory = "/home/tan";

  home.file."tanos/wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Pictures/Wallpapers";
}
