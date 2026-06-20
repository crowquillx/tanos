{
  host = {
    name = "tanlappy";
    isVm = false;
    timeZone = "America/Boise";
    locale = "en_US.UTF-8";
  };

  boot = {
    kernel = "zen";
    systemdBoot.enable = true;
    secureBoot = {
      enable = false;
      includeMicrosoftKeys = true;
      autoEnroll = false;
      pkiBundle = "/etc/secureboot";
    };
  };

  users = {
    primary = "tan";
    extraPackages = [
      "equibop"
      "spotify"
      "mpv"
      "pywalfox-native"
      #      "sops"
      "qbittorrent"
      "mullvad"
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
    extraCompositors = [];
    displayManager = "auto";
    sddm.wayland.enable = false;
    sddm.background = ../../wallpapers/1.png;
    browser = {
      default = "zen";
      zen.enable = true;
      helium.enable = true;
      mullvadBrowser.enable = true;
    };
    niri = {
      outputs = {};
      settings = {};
    };
    noctalia = import ./noctalia;
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
        suspendSeconds = null;
      };
    };
    shellStartupCommand = null;
    startup.apps = [
      "spotify"
      "sleep 5 && equibop"
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
    codingTools = {
      enable = true;
      editors.enable = true;
      aiCli = {
        enable = true;
        codex = {
          enable = true;
          trustedDirectories = [ "/home/tan/tanos" ];
        };
        opencode.enable = true;
        gemini.enable = true;
      };
      nixTools.enable = true;
    };
    mcp.nixos.enable = true;

    ssh = {
      enable = true;
      # Key-only SSH: password and keyboard-interactive auth are disabled.
      passwordAuthentication = false;
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu4u2AElakm7r1HESc19BY3PsfQfkPb/mVoPu+Zw72d3W6qdO9HAT6OM5fxfV6yqQE0aH0ob9AHEI96+qbEx2TC35awUXXetOyMUckXtIqGPzazuBmA/WVoQjbNP2mHirhuUXUMm3sJz+e50riea2fvZ8mS7lTOXmfbnCilWNcKX+0gii1atPU0OMm0pghvGikrj1XcGFA+OcSGZdVSJPTDhfZZE236ch/9UxySFXO4Tk6gDXb46RElkiklGkfo9K0p14rf+XIeoHSvqYHiB0AECf/6t5pm/b5EGQqLaiKLM2b98abUX6N5bElc/Ok2sHw2Rar/8HuSJP0r91H1icqESa24ljl9SWc1rr6LwRx5OW2klwpRy9zdq+tfa3kp2yrAPZEYSFEHsCCzwdhNWq3suJaE/hlFyCJ8sVIiSeXsIjP1u75ek0xRoUdxGdh7w57X2Iud6PdxO/VaFkyZb/h9uYpabc40XChDvZnm2PS7hNre+sKsaLcfYNq4Q9C6Oc= tan@tandesk"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZbQQm+SOtRh2tAbJSa+kkObzIRV4xCkGfFB5eUMcnW tancodes@proton.me"
      ];
    };

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

    tailscale = {
      enable = true;
      exitNode = "tanime-1";
    };
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
      # gaming.enable is false, so these toggles are inert regardless.
      # Set to false to reflect honest intent (no Steam ports on this host).
      steam = {
        gamescopeSession.enable = false;
        remotePlay.openFirewall = false;
        dedicatedServer.openFirewall = false;
        localNetworkGameTransfers.openFirewall = false;
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
