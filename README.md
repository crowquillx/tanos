# tanos

Minimal multi-host NixOS flake with Home Manager, `nixpkgs-unstable`, niri (`Naxdy` fork by default), switchable shell layers (`dms` or `noctalia`), SDDM, and `sops-nix`.

## Hosts

- `tandesk`: physical machine profile
- `tanvm`: VM-first profile (QEMU/KVM + virtio defaults, software-rendering fallback enabled)

Both hosts use username `tan`.

## Layout

- `hosts/<host>/variables.nix`: primary toggle surface
- `hosts/<host>/default.nix`: host-specific wiring
- `modules/nixos/*`: system modules
- `modules/home/*`: Home Manager modules
- `users/tan/home.nix`: user entrypoint

## Key Switches (`hosts/<host>/variables.nix`)

- `desktop.niri.source = "naxdy" | "upstream"`
- `desktop.niri.outputs = { ... }` (host-specific monitor layout for HM niri settings)
- `desktop.niri.blur = { on, radius, noise, brightness, contrast, saturation }` (Naxdy-only blur tuning; ignored on upstream)
- `desktop.shell = "dms" | "noctalia" | "none"`
- `desktop.shellStartupCommand = "<command>"` (optional, for shells that need explicit niri startup command)
- `users.extraPackages = [ "pkgName" "python3Packages.pip" ... ]` (extra HM packages by nixpkgs attr path)
- `desktop.enable = true | false`
- `features.bluetooth.enable = true | false`
- `features.portals.enable = true | false`
- `security.sops.enable = true | false`

## Quick Start (Post-install NixOS)

This repo assumes base NixOS is already installed. It does not partition disks for you.

1. Clone this repo onto the target machine.
2. Pick host:
   - VM test: `tanvm`
   - Physical: `tandesk`
3. Run bootstrap:
   - `sudo ./install/bootstrap.sh tanvm`
   - or `sudo ./install/bootstrap.sh tandesk`
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

## Notes

- `hardware-configuration.nix` placeholders are overwritten by bootstrap.
- `tanvm` defaults disable bluetooth and enable software rendering for reliability.
- This setup targets `nixpkgs-unstable`.
- User-facing desktop packages/shell config are HM-first; system modules keep service/session plumbing.
