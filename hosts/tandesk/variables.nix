{
  host = {
    name = "tandesk";
    isVm = false;
    timeZone = "America/Boise";
    locale = "en_US.UTF-8";
  };

  boot.systemdBoot.enable = true;
  boot.secureBoot = {
    enable = false;
    # Keep Microsoft UEFI CA/3rd-party keys available for dual-boot and vendor tooling.
    includeMicrosoftKeys = true;
    # Set true after reading docs/SECURE_BOOT.md and confirming firmware setup steps.
    autoEnroll = false;
    # Default sbctl/Lanzaboote PKI location.
    pkiBundle = "/etc/secureboot";
  };

  users = {
    primary = "tan";
    extraPackages = [
      "equibop"
      "spotify"
      "mpv"
      "pywalfox-native"
      "sops"
    ];
    git = {
      name = "tan";
      email = "tancodes@proton.me";
    };
  };

  graphics = {
    profile = "nvidia";
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
    };
  };

  desktop = {
    enable = true;
    compositor = "niri";
    extraCompositors = [ ];
    displayManager = "auto";
    sddm.wayland.enable = false;
    sddm.background = "./wallpapers/1.jpg";
    browser = {
      default = "zen";
      firefox.enable = false;
      zen.enable = true;
      chrome.enable = false;
      helium.enable = false;
    };
    niri = {
      useWip = true;
      blur = {
        enable = true;
        passes = 3;
        offset = 3.0;
        noise = 0.03;
        saturation = 1.0;
      };
      outputs = {
        "DP-3" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 180.002;
          };
          scale = 1;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = {
            x = 2560;
            y = 1080;
          };
          variableRefreshRate = "on-demand";
          focusAtStartup = true;
        };
        "DP-2" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 164.999;
          };
          scale = 1;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = {
            x = 0;
            y = 1080;
          };
        };
        "DP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.001;
          };
          scale = 1;
          transform = {
            rotation = 0;
            flipped = false;
          };
          position = {
            x = 2560;
            y = 0;
          };
        };
      };
      settings = { };
    };
    noctalia = import ./noctalia;
    session = {
      enable = true;
      polkit.enable = true;
      keyring.enable = true;
      lock = {
        enable = true;
        command = "tanos-noctalia-shell ipc call lockScreen lock";
        idleSeconds = 300;
        beforeSleep = true;
        onLidClose = true;
      };
      idle = {
        screenOffSeconds = 600;
        suspendSeconds = 1800;
      };
    };
    shellStartupCommand = null;
    startup.apps = [
      "spotify"
      "equibop"
    ];
    startup.backend = "niri";
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
    mcp.nixos.enable = true;
    fileManager.thunar.enable = true;
    terminals.kitty.enable = true;
    theme = {
      gtk = {
        enable = true;
        iconTheme = {
          name = "rose-pine";
          package = "rose-pine-icon-theme";
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
      packages = [
        "org.upscayl.Upscayl"
      ];
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
