{
  host = {
    name = "tanlappy";
    isVm = false;
    timeZone = "America/Boise";
    locale = "en_US.UTF-8";
  };

  boot.kernel = "zen";
  boot.systemdBoot.enable = true;
  boot.secureBoot = {
    enable = false;
    includeMicrosoftKeys = true;
    autoEnroll = false;
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
      "brave"
      "qbittorrent"
    ];
    git = {
      name = "tan";
      email = "tancodes@proton.me";
    };
  };

  graphics = {
    profile = "amd";
  };

  desktop = {
    enable = true;
    compositor = "niri";
    extraCompositors = [ ];
    displayManager = "auto";
    sddm.wayland.enable = false;
    sddm.background = ../../wallpapers/1.png;
    browser = {
      default = "zen";
      firefox.enable = false;
      zen.enable = true;
      chrome.enable = false;
      helium.enable = true;
    };
    niri = {
      useWip = false;
      blur = {
        enable = true;
        passes = 3;
        offset = 3.0;
        noise = 0.03;
        saturation = 1.0;
      };
      outputs = { };
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
        suspendSeconds = null;
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
        podman.enable = true;
        docker.enable = false;
      };
    };

    laptop = {
      enable = true;

      upower.enable = true;
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
    enable = false;
    defaultSopsFile = ../../secrets/tanlappy.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
