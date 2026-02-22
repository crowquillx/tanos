{
  host = {
    name = "tanlappy";
    isVm = false;
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
    # Keep neutral until hardware is confirmed. Set to "intel"/"amd"/"nvidia" when known.
    profile = "auto";
  };

  desktop = {
    enable = true;
    compositor = "niri";
    displayManager = "auto";
    browser = {
      default = "zen";
      firefox.enable = true;
      zen.enable = true;
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
    shellStartupCommand = null;
    niri = {
      source = "naxdy";

      # Leave empty to use runtime output discovery on this host.
      outputs = { };

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
    bluetooth.enable = true;
    networking.networkmanager.enable = true;
    portals.enable = true;
    printing.enable = false;
    flatpak.enable = false;
    gaming.enable = false;

    laptop = {
      enable = true;

      # Helpful laptop defaults with explicit toggles per service.
      upower.enable = true;
      # DMS enables power-profiles-daemon; keep TLP off to avoid the NixOS conflict assertion.
      tlp.enable = false;
      thermald.enable = true;
      powertop.enable = false;
      fwupd.enable = true;

      logind = {
        lidSwitch = "suspend";
        lidSwitchExternalPower = "ignore";
        lidSwitchDocked = "ignore";
      };
    };
  };

  security.sops = {
    # Start disabled until tanlappy secrets are created.
    enable = false;
    defaultSopsFile = ../../secrets/tanlappy.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
