{ combined, config, ... }:
{
  imports = combined.homeModules;

  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/tanos/wallpapers";
}
