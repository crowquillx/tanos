# Host Variables Reference

Primary host configuration is in `hosts/<host>/variables.nix`.

## Key switches

- `desktop.compositor = "niri" | "plasma"`
- `desktop.extraCompositors = [ "niri" "plasma" ... ]` (optional additional installed sessions; first login default still comes from `desktop.compositor`)
- `desktop.displayManager = "auto" | "sddm"`
- `desktop.sddm.wayland.enable = true | false`
- `desktop.browser.default = "firefox" | "zen" | "chrome" | "helium"`
- `desktop.browser.<name>.enable = true | false` for `firefox`, `zen`, `chrome`, `helium`
- `desktop.niri.outputs = { "<output-name>" = { scale, position = { x, y; }, mode = { width, height, refresh; }, "focus-at-startup", transform = { rotation, flipped; }, "variable-refresh-rate" }; ... }`
- `desktop.niri.settings = { ... }`
- `desktop.niri.useWip = true | false` (switches niri input from stable to the WIP override target in `flake.nix`, currently `niri-wm/niri` PR `#3483`)
- `desktop.noctalia = { enable, command, systemd.enable, assistantPanel.secrets, settings, colors, plugins, pluginSettings, userTemplates }`
- `graphics.profile = "auto" | "none" | "amd" | "intel" | "nvidia" | "vm"`
- `graphics.nvidia = { modesetting.enable, powerManagement.enable, open }`
- `graphics.extraPackages = [ "pkgAttr.path" ... ]`
- `boot.secureBoot = { enable, includeMicrosoftKeys, autoEnroll, pkiBundle }` (Lanzaboote-based secure boot)
- `desktop.shellStartupCommand = "<command>"`
- `desktop.startup.backend = "systemd" | "niri"`
- `desktop.startup.apps = [ "<cmd>" ... ]`
- `desktop.session.polkit.enable = true | false`
- `desktop.session.keyring.enable = true | false`
- `desktop.session.lock = { enable, command, idleSeconds, beforeSleep, onLidClose }`
- `desktop.session.idle = { screenOffSeconds, suspendSeconds }`
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
- `features.codingTools.enable = true | false`
- `features.mcp.nixos.enable = true | false`
- `features.fileManager.thunar.enable = true | false`
- `features.services = { fstrim.enable, resolved.enable, powerProfilesDaemon.enable }`
- `features.flatpak = { enable, packages = [ "<app-id>" ... ] }`
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

### Desktop startup apps

```nix
desktop.startup = {
  backend = "systemd";
  apps = [
    "wl-paste --watch cliphist store"
    "spotify"
    "equibop"
  ];
};
```

`backend = "systemd"` manages the apps as Home Manager user services under `wayland.systemd.target`, which means they can be restarted during `rebuild switch`.

For Niri hosts, use:

```nix
desktop.startup = {
  backend = "niri";
  apps = [
    "spotify"
    "equibop"
  ];
};
```

This uses Niri `spawn-at-startup`, so the apps start when the session starts but are not bounced by Home Manager user-service reloads during rebuilds.

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
  command = "noctalia-shell";
  systemd.enable = true;
  assistantPanel.secrets = {
    googleApiKey = "noctalia-ap-google-api-key";
  };
  settings = { };
  colors = { };
  plugins = { };
  pluginSettings = { };
  userTemplates = { };
};
```

This is passed directly to Home Manager's `programs.noctalia-shell.*` options, so the shell stays fully HM-managed.
When `desktop.noctalia.command` is set to a wrapper such as `tanos-noctalia-shell`, Niri startup and Noctalia IPC keybinds will use that command instead of plain `noctalia-shell`.
On Noctalia-enabled Niri hosts, Noctalia is also the idle manager. Use `desktop.session.lock.command`, `desktop.session.lock.idleSeconds`, `desktop.session.idle.screenOffSeconds`, and `desktop.session.idle.suspendSeconds` as the source of truth instead of configuring `swayidle`.

For per-monitor wallpaper rotation, set `desktop.noctalia.settings.wallpaper.setWallpaperOnAllMonitors = false;` and keep `wallpaperChangeMode = "random"`.

`desktop.noctalia.assistantPanel.secrets` names optional `sops-nix` secrets that are exposed to the plugin through its documented environment variables. Set only the ones you actually use:

- `NOCTALIA_AP_GOOGLE_API_KEY`
- `NOCTALIA_AP_OPENAI_COMPATIBLE_API_KEY`
- `NOCTALIA_AP_DEEPL_API_KEY`

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
  packages = [
    "com.spotify.Client"
    "md.obsidian.Obsidian"
  ];
};
```

Declared `features.flatpak.packages` entries are installed declaratively via `nix-flatpak`. Removing an entry converges the system-wide Flatpak set back to the declared list on the next rebuild.

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
