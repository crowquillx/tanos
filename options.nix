# PLEASE READ THE WIKI FOR DETERMINING
# VALUES FOR THIS PAGE. 
# https://gitlab.com/Zaney/zaneyos/-/wikis/Setting-Options

let
  # YOU MUST CHANGE THIS 
  userHome = "/home/tan";
in {
  # User Variables
  gitUsername = "Tanner Decker";
  gitEmail = "tancodes@proton.me";
  theme = "catppuccin-macchiato";
  slickbar = true;
  borderAnim = true;
  browser = "firefox";
  wallpaperGit = "git@github.com:crowquillx/wallpapers.git";
  wallpaperDir = "${userHome}/Pictures/Wallpapers";
  flakeDir = "${userHome}/tanos";
  screenshotDir = "${userHome}/Pictures/Screenshots";
  terminal = "alacritty";

  # System Settings
  theLocale = "en_US.UTF-8";
  theKBDLayout = "us";
  theSecondKBDLayout = "pl";
  theLCVariables = "en_US.UTF-8";
  theTimezone = "America/Boise";
  theShell = "zsh"; # Possible options: bash, zsh
  # For Hybrid Systems intel-nvidia
  # Should Be Used As gpuType
  cpuType = "amd";
  gpuType = "amd";

  # Nvidia Hybrid Devices
  # ONLY NEEDED FOR HYBRID
  # SYSTEMS! 
  #intel-bus-id = "PCI:0:2:0";
  #nvidia-bus-id = "PCI:14:0:0";

  # Enable / Setup NFS
  nfs = false;
  nfsMountPoint = "/mnt/nas";
  nfsDevice = "nas:/volume1/nas";

  # Printer, NTP, HWClock Settings
  localHWClock = true;
  ntp = true;
  printer = false;

  # Enable Flatpak & Larger Programs
  flatpak = false;
  kdenlive = false;
  blender = false;

  # Enable Support For
  # Logitech Devices
  logitech = true;

  # Enable Terminals
  # If You Disable All You Get Kitty
  wezterm = false;
  alacritty = true;
  kitty = false;

  # Enable Python & PyCharm
  python = false;

}
