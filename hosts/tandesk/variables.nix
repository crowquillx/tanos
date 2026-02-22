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
    git = {
      name = null;
      email = null;
    };
  };

  graphics = {
    # "auto" resolves to "none" on non-VM hosts until you set "amd", "intel", or "nvidia".
    profile = "auto";
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
  };

  features = {
    stylix = {
      enable = true;
      variant = "moon";
    };

    shell = {
      fish.enable = true;
      starship.enable = true;
    };

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };

    audio.enable = true;
    codingTools.enable = true;
    fileManager.thunar.enable = true;
    terminals.kitty.enable = true;
    theme = {
      gtk = {
        enable = true;
        iconTheme = {
          name = "MoreWaita";
          package = "morewaita-icon-theme";
        };
      };
      qt.enable = true;
    };
    zoxide.enable = true;
    bluetooth.enable = true;
    networking.networkmanager.enable = true;
    portals.enable = true;
    services = {
      fstrim.enable = true;
      resolved.enable = true;
      powerProfilesDaemon.enable = true;
    };
    printing.enable = false;
    flatpak = {
      enable = true;
    };
    gaming = {
      enable = true;
      steam = {
        gamescopeSession.enable = false;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
    };
    virtualisation = {
      vmHost = {
        enable = false;
        spiceUSBRedirection.enable = true;
      };
      containers = {
        podman.enable = false;
        docker.enable = false;
      };
    };
  };

  security.sops = {
    enable = true;
    defaultSopsFile = ../../secrets/tandesk.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
