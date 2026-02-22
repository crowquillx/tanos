{
  host = {
    name = "tanvm";
    isVm = true;
    timeZone = "America/Chicago";
    locale = "en_US.UTF-8";
  };

  boot.systemdBoot.enable = true;

  users = {
    primary = "tan";
    extraPackages = [ ];
  };

  desktop = {
    enable = true;
    compositor = "niri";
    displayManager = "sddm";
    shell = "dms";
    # Example: "dms run --session", "noctalia-shell", or another launcher command.
    shellStartupCommand = null;
    niri = {
      source = "naxdy";

      # Leave empty to use runtime output discovery on this host.
      outputs = { };

      # Naxdy blur defaults (overrides source-based fallback explicitly).
      blur = {
        on = true;
        radius = 7.5;
        noise = 0.054;
        brightness = 0.817;
        contrast = 1.3;
        saturation = 1.08;
      };
    };
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
