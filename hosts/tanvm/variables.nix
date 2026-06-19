{
  host = {
    name = "tanvm";
    isVm = true;
    timeZone = "America/Chicago";
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
      "mullvad"
    ];
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
    extraCompositors = [];
    displayManager = "auto";
    browser = {
      default = "mullvadBrowser";
      zen.enable = false;
      helium.enable = false;
      mullvadBrowser.enable = true;
    };
    niri = {
      # Populate output names with `niri msg outputs`.
      outputs = {};
      settings = {};
    };
    noctalia = {
      enable = true;
      systemd.enable = false;
      settings = {};
      colors = {};
      plugins = {};
      pluginSettings = {};
      userTemplates = {};
    };
    session = {
      enable = true;
      polkit.enable = true;
      keyring.enable = true;
      lock = {
        enable = true;
        command = "tanos-noctalia-shell msg session lock";
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
    codingTools.enable = false;
    mcp.nixos.enable = true;
    tailscale.enable = true;
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
    bluetooth.enable = false;
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
      enable = false;
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
    defaultSopsFile = ../../secrets/tanvm.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
