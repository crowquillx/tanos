{
  host = {
    name = "tandesk";
    isVm = false;
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

      # Host-specific monitor layout for Niri HM settings.
      outputs = {
        "DP-3" = {
          mode = "2560x1440@180.002";
          scale = 1.0;
          transform = "normal";
          position = { x = 2560; y = 1080; };
          variable-refresh-rate = { on-demand = true; };
          focus-at-startup = true;
        };
        "DP-2" = {
          mode = "2560x1440@164.999";
          scale = 1.0;
          transform = "normal";
          position = { x = 0; y = 1080; };
        };
        "DP-1" = {
          mode = "1920x1080@144.001";
          scale = 1.0;
          transform = "normal";
          position = { x = 2560; y = 0; };
        };
      };

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
    vm.softwareRendering.enable = false;
  };

  features = {
    audio.enable = true;
    bluetooth.enable = true;
    networking.networkmanager.enable = true;
    portals.enable = true;
    printing.enable = false;
    flatpak.enable = false;
    gaming.enable = false;
  };

  security.sops = {
    enable = true;
    defaultSopsFile = ../../secrets/tandesk.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
