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

    swap = {
      zram = {
        enable = true;
        memoryPercent = 25;
      };
      disk = {
        enable = true;
        path = "/var/lib/swapfile";
        sizeMiB = 4096;
      };
      swappiness = 10;
    };

    nixMaintenance = {
      gc.enable = false;
      optimise = {
        enable = true;
        dates = "weekly";
      };
    };

    audio.enable = true;

    ssh = {
      enable = true;
      # Key-only SSH: password and keyboard-interactive auth are disabled.
      passwordAuthentication = false;
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu4u2AElakm7r1HESc19BY3PsfQfkPb/mVoPu+Zw72d3W6qdO9HAT6OM5fxfV6yqQE0aH0ob9AHEI96+qbEx2TC35awUXXetOyMUckXtIqGPzazuBmA/WVoQjbNP2mHirhuUXUMm3sJz+e50riea2fvZ8mS7lTOXmfbnCilWNcKX+0gii1atPU0OMm0pghvGikrj1XcGFA+OcSGZdVSJPTDhfZZE236ch/9UxySFXO4Tk6gDXb46RElkiklGkfo9K0p14rf+XIeoHSvqYHiB0AECf/6t5pm/b5EGQqLaiKLM2b98abUX6N5bElc/Ok2sHw2Rar/8HuSJP0r91H1icqESa24ljl9SWc1rr6LwRx5OW2klwpRy9zdq+tfa3kp2yrAPZEYSFEHsCCzwdhNWq3suJaE/hlFyCJ8sVIiSeXsIjP1u75ek0xRoUdxGdh7w57X2Iud6PdxO/VaFkyZb/h9uYpabc40XChDvZnm2PS7hNre+sKsaLcfYNq4Q9C6Oc= tan@tandesk"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZbQQm+SOtRh2tAbJSa+kkObzIRV4xCkGfFB5eUMcnW tancodes@proton.me"
      ];
    };

  };

  security.sops = {
    enable = true;
    defaultSopsFile = ../../secrets/tanvm.yaml;
    ageKeyFile = "/var/lib/sops-nix/key.txt";
  };
}
