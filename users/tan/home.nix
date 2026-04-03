{ combined, ... }:
{
  imports = combined.homeModules;

  home.username = "tan";
  home.homeDirectory = "/home/tan";
}
