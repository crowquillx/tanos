# Host Variables Reference

Primary host configuration is in `hosts/<host>/variables.nix`.

## Key switches

- `desktop.niri.source = "naxdy" | "upstream"`
- `desktop.displayManager = "auto" | "dms-greeter" | "sddm"`
- `desktop.browser.default = "firefox" | "zen" | "chrome" | "helium"`
- `desktop.browser.<name>.enable = true | false` for `firefox`, `zen`, `chrome`, `helium`
- `graphics.profile = "auto" | "none" | "amd" | "intel" | "nvidia" | "vm"`
- `graphics.nvidia = { modesetting.enable, powerManagement.enable, open }`
- `graphics.extraPackages = [ "pkgAttr.path" ... ]`
- `desktop.niri.outputs = { ... }`
- `desktop.niri.blur = { on, radius, noise, brightness, contrast, saturation }`
- `desktop.shell = "dms" | "noctalia" | "none"`
- `desktop.shellStartupCommand = "<command>"`
- `desktop.session.polkit.enable = true | false`
- `desktop.session.keyring.enable = true | false`
- `desktop.session.lock = { enable, command, idleSeconds, beforeSleep, onLidClose }`
- `users.git = { name, email }`
- `users.extraPackages = [ "pkgName" "python3Packages.pip" ... ]`
- `desktop.enable = true | false`
- `features.stylix = { enable, variant }`
- `features.shell = { fish.enable, starship.enable }`
- `features.nh = { enable, clean.enable, clean.extraArgs }`
- `features.terminals.kitty.enable = true | false`
- `features.theme.gtk = { enable, iconTheme.name, iconTheme.package }`
- `features.theme.qt.enable = true | false`
- `features.zoxide.enable = true | false`
- `features.bluetooth.enable = true | false`
- `features.portals.enable = true | false`
- `features.danksearch.enable = true | false`
- `features.codingTools.enable = true | false`
- `features.fileManager.thunar.enable = true | false`
- `features.services = { fstrim.enable, resolved.enable, powerProfilesDaemon.enable }`
- `features.flatpak.enable = true | false`
- `features.gaming = { enable, steam.gamescopeSession.enable, steam.remotePlay.openFirewall, steam.dedicatedServer.openFirewall, steam.localNetworkGameTransfers.openFirewall }`
- `features.virtualisation.vmHost = { enable, spiceUSBRedirection.enable }`
- `features.virtualisation.containers = { podman.enable, docker.enable }`
- `features.laptop.enable = true | false`
- `features.laptop.tlp.enable = true | false`
- `features.laptop.thermald.enable = true | false`
- `features.laptop.upower.enable = true | false`
- `features.laptop.powertop.enable = true | false`
- `features.laptop.fwupd.enable = true | false`
- `features.laptop.logind = { lidSwitch, lidSwitchExternalPower, lidSwitchDocked }`
- `security.sops.enable = true | false`

## Common snippets

### Stylix (Rose Pine)

```nix
features.stylix = {
  enable = true;
  variant = "moon";
};
```

### Fish + starship + zoxide

```nix
features = {
  shell = {
    fish.enable = true;
    starship.enable = true;
  };
  zoxide.enable = true;
};
```

### NH

```nix
features.nh = {
  enable = true;
  clean = {
    enable = true;
    extraArgs = "--keep-since 4d --keep 3";
  };
};
```

### Flatpak

```nix
features.flatpak = {
  enable = true;
};
```

### GTK / QT / Kitty

```nix
features = {
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
};
```

### Steam

```nix
features.gaming = {
  enable = true;
  steam = {
    gamescopeSession.enable = false;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
};
```

### Virtualization (VM host + containers)

```nix
features.virtualisation = {
  vmHost = {
    enable = false;
    spiceUSBRedirection.enable = true;
  };
  containers = {
    podman.enable = false;
    docker.enable = false;
  };
};
```

### Niri source

```nix
desktop.niri = {
  source = "naxdy";
  # source = "upstream";
};
```

### Laptop defaults

```nix
features.laptop = {
  enable = true;
  upower.enable = true;
  tlp.enable = true;
  thermald.enable = true;
  powertop.enable = false;
  fwupd.enable = true;
  logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };
};
```

### Git identity

```nix
users.git = {
  name = "Tan User";
  email = "tan@example.com";
};
```

Set both fields together, or leave both `null`.
