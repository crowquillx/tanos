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
    startup.apps = [
      "wl-paste --watch cliphist store"
      "qs -c ii"
      "spotify"
      "equibop"
    ];
    niri = {
      # Host-specific monitor layout for Niri HM settings.
      outputs = {
        "DP-3" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 180.002;
          };
          scale = 1.0;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = { x = 2560; y = 1080; };
          variable-refresh-rate = "on-demand";
          focus-at-startup = true;
        };
        "DP-2" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 164.999;
          };
          scale = 1.0;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = { x = 0; y = 1080; };
        };
        "DP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.001;
          };
          scale = 1.0;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = { x = 2560; y = 0; };
        };
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
