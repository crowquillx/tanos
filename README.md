# tanos

Minimal multi-host NixOS flake with Home Manager, `nixpkgs-unstable`, niri (`Naxdy` fork by default), switchable shell layers (`dms` or `noctalia`), SDDM, and `sops-nix`.

## Hosts

- `tandesk`: physical machine profile
- `tanvm`: VM-first profile (QEMU/KVM + virtio defaults, software-rendering fallback enabled)
- `tanlappy`: laptop profile (power/lid/battery defaults enabled)

All hosts use username `tan`.

## Layout

- `hosts/<host>/variables.nix`: primary toggle surface
- `hosts/<host>/default.nix`: host-specific wiring
- `modules/nixos/*`: system modules
- `modules/home/*`: Home Manager modules
- `users/tan/home.nix`: user entrypoint

## Key Switches (`hosts/<host>/variables.nix`)

- `desktop.niri.source = "naxdy" | "upstream"`
- `desktop.displayManager = "auto" | "dms-greeter" | "sddm"`
- `desktop.browser.default = "firefox" | "zen" | "chrome" | "helium"`
- `desktop.browser.<name>.enable = true | false` for `firefox`, `zen`, `chrome`, `helium`
- `graphics.profile = "auto" | "none" | "amd" | "intel" | "nvidia" | "vm"`
- `graphics.nvidia = { modesetting.enable, powerManagement.enable, open }` (optional nvidia overrides)
- `graphics.extraPackages = [ "pkgAttr.path" ... ]` (optional GPU package extensions from nixpkgs)
- `desktop.niri.outputs = { ... }` (host-specific monitor layout for HM niri settings)
- `desktop.niri.blur = { on, radius, noise, brightness, contrast, saturation }` (Naxdy-only blur tuning; ignored on upstream)
- `desktop.shell = "dms" | "noctalia" | "none"`
- `desktop.shellStartupCommand = "<command>"` (optional, for shells that need explicit niri startup command)
- `desktop.session.polkit.enable = true | false`
- `desktop.session.keyring.enable = true | false`
- `desktop.session.lock = { enable, command, idleSeconds, beforeSleep, onLidClose }`
- `users.extraPackages = [ "pkgName" "python3Packages.pip" ... ]` (extra HM packages by nixpkgs attr path)
- `desktop.enable = true | false`
- `features.bluetooth.enable = true | false`
- `features.portals.enable = true | false`
- `features.danksearch.enable = true | false` (defaults to true; installs/enables DankSearch HM module)
- `features.laptop.enable = true | false`
- `features.laptop.tlp.enable = true | false`
- `features.laptop.thermald.enable = true | false`
- `features.laptop.upower.enable = true | false`
- `features.laptop.powertop.enable = true | false`
- `features.laptop.fwupd.enable = true | false`
- `features.laptop.logind = { lidSwitch, lidSwitchExternalPower, lidSwitchDocked }`
- `security.sops.enable = true | false`

## Quick Start (Post-install NixOS)

This repo assumes base NixOS is already installed. It does not partition disks for you.

1. Clone this repo onto the target machine.
2. Pick host:
   - VM test: `tanvm`
   - Physical: `tandesk`
   - Laptop: `tanlappy`
3. Run bootstrap:
   - `sudo ./install/bootstrap.sh tanvm`
   - or `sudo ./install/bootstrap.sh tandesk`
   - or `sudo ./install/bootstrap.sh tanlappy`
4. Reboot and log in through SDDM (niri session).

## VM Testing Flow

Use `tanvm` first, then move to `tandesk`.

1. Install baseline NixOS in VM (UEFI + ext4 root recommended).
2. Clone repo in the VM.
3. Run `sudo ./install/bootstrap.sh tanvm`.
4. Validate login + niri + shell startup.
5. Iterate on `hosts/tanvm/variables.nix`.

## Switching Niri Source

Edit host variables:

```nix
desktop.niri = {
  source = "naxdy"; # current default
  # source = "upstream";
  outputs = {
    "eDP-1" = {
      mode = "1920x1080@60";
      scale = 1.0;
      transform = "normal";
      position = { x = 0; y = 0; };
    };
  };
  blur = {
    on = true;
    radius = 7.5;
    noise = 0.054;
    brightness = 0.817;
    contrast = 1.3;
    saturation = 1.08;
  };
};
```

Apply:

```bash
sudo nixos-rebuild switch --flake .#tanvm
```

## Switching Shell Layer

Edit host variables:

```nix
desktop.shell = "dms";
# desktop.shell = "noctalia";
# desktop.shell = "none";
```

Apply:

```bash
sudo nixos-rebuild switch --flake .#tanvm
```

## Display Manager Selection

Set display manager policy per host:

```nix
desktop.displayManager = "auto";
# desktop.displayManager = "dms-greeter";
# desktop.displayManager = "sddm";
```

`auto` behavior:
- `desktop.shell = "dms"` -> uses `dms-greeter` (quickshell greeter)
- `desktop.shell = "noctalia"` -> uses `sddm`

`dms-greeter` is supported only when `desktop.shell = "dms"`.

## Browser Selection

Set browser per host in `hosts/<host>/variables.nix`:

```nix
desktop.browser = {
  default = "firefox";
  firefox.enable = true;
  zen.enable = false;
  chrome.enable = false;
  helium.enable = false;
};
```

Enabled browsers are installed via Home Manager. `desktop.browser.default` sets the default for:
- `text/html`
- `application/xhtml+xml`
- `x-scheme-handler/http`
- `x-scheme-handler/https`

## DankSearch

DankSearch is installed/enabled via Home Manager by default.

Optional toggle:

```nix
features.danksearch.enable = true;
# features.danksearch.enable = false;
```

## Session Runtime (Polkit, Keyring, Idle Lock)

Set session behavior per host in `hosts/<host>/variables.nix`:

```nix
desktop.session = {
  enable = true;
  polkit.enable = true;
  keyring.enable = true;
  lock = {
    enable = true;
    command = "loginctl lock-session"; # replace with shell lock command if needed
    idleSeconds = 600;
    beforeSleep = true;
    onLidClose = true;
  };
};
```

This provides:
- a robust polkit agent startup from Nix store paths
- gnome-keyring integration via PAM + keyring service
- idle lock using `swayidle`, plus pre-sleep locking

Notifications are intentionally shell-owned in this repo (no standalone notification daemon module).

## GPU Profiles

Set GPU behavior per host in `hosts/<host>/variables.nix`:

```nix
graphics = {
  profile = "auto";
  # profile = "amd";
  # profile = "intel";
  # profile = "nvidia";
  # profile = "vm";
};
```

`auto` behavior:
- VM hosts (`host.isVm = true`) resolve to `vm` and force software rendering env vars.
- Non-VM hosts resolve to `none` (neutral/no forced vendor driver) until explicitly set.

Optional NVIDIA tuning:

```nix
graphics = {
  profile = "nvidia";
  nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
  };
};
```

Optional extra graphics packages by nixpkgs attribute path:

```nix
graphics.extraPackages = [
  "intel-media-driver"
];
```

## Laptop Features

Enable laptop defaults in `hosts/<host>/variables.nix`:

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

This enables practical laptop behavior:
- battery reporting via `upower` (aligned with ZaneyOS laptop battery handling)
- power tuning via `tlp` + `thermald`
- safe lid behavior via `services.logind` settings
- firmware updates via `fwupd`
- lock-on-lid-close compatibility through `desktop.session.lock.onLidClose`

## sops-nix Setup

### 1) Generate host key (if missing)

```bash
sudo mkdir -p /var/lib/sops-nix
sudo nix shell nixpkgs#age --command age-keygen -o /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
sudo cat /var/lib/sops-nix/key.txt | grep "^# public key:" | cut -d' ' -f4
```

Take that public key and add it to `.sops.yaml` recipients.

### 2) Create encrypted host secret file

```bash
mkdir -p secrets
sops secrets/tanvm.yaml
```

### 3) Point variables to the file

`hosts/tanvm/variables.nix` already points to `../../secrets/tanvm.yaml`.

## Add a New Host

1. Copy `hosts/tanvm` to `hosts/<newhost>`.
2. Update `hosts/<newhost>/variables.nix`.
3. Add `nixosConfigurations.<newhost>` in `flake.nix`.
4. Run bootstrap on that machine/VM.

## Build Commands

- `sudo nixos-rebuild build --flake .#tanvm`
- `sudo nixos-rebuild switch --flake .#tanvm`
- `sudo nixos-rebuild build --flake .#tandesk`
- `sudo nixos-rebuild build --flake .#tanlappy`

## Notes

- `hardware-configuration.nix` placeholders are overwritten by bootstrap.
- `tanvm` defaults disable bluetooth and use `graphics.profile = "vm"` for software-rendering reliability.
- `tanlappy` enables `features.laptop` defaults and leaves monitor layout on runtime discovery.
- This setup targets `nixpkgs-unstable`.
- User-facing desktop packages/shell config are HM-first; system modules keep service/session plumbing.
