# Host Variables Reference

Primary host configuration is in `hosts/<host>/variables.nix`.

## Key switches

- `desktop.compositor = "niri" | "plasma"`
- `desktop.extraCompositors = [ "niri" "plasma" ... ]` (optional additional installed sessions; first login default still comes from `desktop.compositor`)
- `desktop.displayManager = "auto" | "sddm"`
- `desktop.browser.default = "firefox" | "zen" | "chrome" | "helium"`
- `desktop.browser.<name>.enable = true | false` for `firefox`, `zen`, `chrome`, `helium`
- `desktop.niri.outputs = { "<output-name>" = { scale, position = { x, y; }, mode = { width, height, refresh; }, "focus-at-startup", transform = { rotation, flipped; }, "variable-refresh-rate" }; ... }`
- `desktop.niri.settings = { ... }`
- `desktop.niri.useWip = true | false` (switches niri input from stable branch to `wip`)
- `desktop.noctalia = { enable, systemd.enable, settings, colors, plugins, pluginSettings, userTemplates }`
- `graphics.profile = "auto" | "none" | "amd" | "intel" | "nvidia" | "vm"`
- `graphics.nvidia = { modesetting.enable, powerManagement.enable, open }`
- `graphics.extraPackages = [ "pkgAttr.path" ... ]`
- `desktop.shellStartupCommand = "<command>"`
- `desktop.startup.apps = [ "<cmd>" ... ]`
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

### Desktop startup apps (systemd user services)

```nix
desktop.startup.apps = [
  "wl-paste --watch cliphist store"
  "spotify"
  "equibop"
];
```

These are started as Home Manager-managed user services under `wayland.systemd.target`.

### Niri monitor configuration

```nix
desktop.niri = {
  outputs = {
    "eDP-1" = {
      scale = 2.0;
      "focus-at-startup" = true;
      position = {
        x = 0;
        y = 0;
      };
    };
  };

  settings = {
    "prefer-no-csd" = true;
  };
};
```

Use `niri msg outputs` from inside a running Niri session to discover the output names and supported modes.

### Install both Niri and Plasma sessions

```nix
desktop = {
  # Default selected in SDDM.
  compositor = "niri";

  # Also install Plasma so both sessions are available at login.
  extraCompositors = [ "plasma" ];
};
```

### Noctalia shell

```nix
desktop.noctalia = {
  enable = true;
  systemd.enable = true;
  settings = { };
  colors = { };
  plugins = { };
  pluginSettings = { };
  userTemplates = { };
};
```

This is passed directly to Home Manager's `programs.noctalia-shell.*` options, so the shell stays fully HM-managed.

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
