{
  host = {
    name = "tanvm";
    isVm = true;
    timeZone = "America/Chicago";
    locale = "en_US.UTF-8";
  };

  boot.systemdBoot.enable = true;

  users.primary = "tan";

  desktop = {
    enable = true;
    compositor = "niri";
    displayManager = "sddm";
    shell = "dms";
    # Example: "dank-material-shell" or another launcher command if required.
    shellStartupCommand = null;
    niri.source = "naxdy";
    vm.softwareRendering.enable = true;
  };

  features = {
    audio.enable = true;
    bluetooth.enable = false;
    networking.networkmanager.enable = true;
    portals.enable = true;
    printing.enable = false;
    flatpak.enable = false;
    gaming.enable = false;
  };

  security.sops = {
    enable = true;
    defaultSopsFile = ../../secrets/tanvm.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
