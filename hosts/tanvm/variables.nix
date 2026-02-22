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
    git = {
      name = null;
      email = null;
    };
  };

  graphics = {
    profile = "vm";
  };

  desktop = {
    enable = true;
    compositor = "niri";
    displayManager = "auto";
    browser = {
      default = "firefox";
      firefox.enable = true;
      zen.enable = false;
      chrome.enable = false;
      helium.enable = false;
    };
    session = {
      enable = true;
      polkit.enable = true;
      keyring.enable = true;
      lock = {
        enable = true;
        # Replace with your shell-specific lock command if desired.
        command = "loginctl lock-session";
        idleSeconds = 600;
        beforeSleep = true;
        onLidClose = true;
      };
    };
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
