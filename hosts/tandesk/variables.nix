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
    extraPackages = [ ];
    git = {
      name = "tan";
      email = "tancodes@proton.me";
    };
  };

  graphics = {
    profile = "nvidia";
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = true;
    };
  };

  desktop = {
    enable = true;
    compositor = "niri";
    extraCompositors = [ ];
    displayManager = "auto";
    sddm.wayland.enable = false;
    browser = {
      default = "zen";
      firefox.enable = false;
      zen.enable = true;
      chrome.enable = false;
      helium.enable = false;
    };
    niri = {
      useWip = true;
      # Populate output names with `niri msg outputs`.
      outputs = { };
      settings = { };
    };
    noctalia = {
      enable = true;
      systemd.enable = true;
      settings = { };
      colors = { };
      plugins = { };
      pluginSettings = { };
      userTemplates = { };
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
    shellStartupCommand = null;
    startup.apps = [
      "wl-paste --watch cliphist store"
      "spotify"
      "equibop"
    ];
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
