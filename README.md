# tanos

Minimal multi-host NixOS flake with Home Manager, `nixpkgs-unstable`, niri (`Naxdy` fork by default), switchable shell layers (`dms` or `noctalia`), SDDM, Stylix (Rose Pine), fish + starship, NH, and `sops-nix`.

## Hosts

- `tandesk`: physical machine profile
- `tanvm`: VM-first profile (QEMU/KVM + virtio defaults, software-rendering fallback enabled)
- `tanlappy`: laptop profile (power/lid/battery defaults enabled)

All hosts currently use username `tan`.

## Layout

- `hosts/<host>/variables.nix`: host toggles and values
- `hosts/<host>/default.nix`: host-specific wiring
- `modules/nixos/*`: system modules
- `modules/home/*`: Home Manager modules
- `users/tan/home.nix`: user entrypoint

## Quick Start (Post-install NixOS)

This repo assumes base NixOS is already installed.

1. Clone this repo onto the target machine.
2. Pick host: `tanvm`, `tandesk`, or `tanlappy`.
3. Run bootstrap:
   - `sudo ./install/bootstrap.sh tanvm`
   - `sudo ./install/bootstrap.sh tandesk`
   - `sudo ./install/bootstrap.sh tanlappy`
4. Reboot and log in through SDDM (niri session).

## tcli

`tcli` is installed via Home Manager and is the recommended day-to-day command for this repo.

It handles both layers every time:

1. NixOS system rebuild (`nixos-rebuild`)
2. Home Manager rebuild (`home-manager` via flake `homeConfigurations`)

Commands:

- `tcli rebuild [switch|build|test|boot] [host]`
- `tcli update [host]`
- `tcli gc`
- `tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]`
- `tcli nh home [switch|build] [host] [-- <nh-args...>]`
- `tcli nh clean [-- <nh-args...>]`

Defaults:

- host defaults to current machine hostname
- flake path defaults to current repo root (or `TANOS_FLAKE_DIR`)

Short aliases (bash + fish):

- `fu` -> `tcli update`
- `fr` -> `tcli rebuild`
- `ncg` -> `tcli gc`

Detailed command behavior and resolution logic: `docs/TCLI.md`.

## Core Commands

- Bootstrap with full system + HM activation:
  - `sudo ./install/bootstrap.sh <host>`
- System build:
  - `sudo nixos-rebuild build --flake .#<host>`
- System switch:
  - `sudo nixos-rebuild switch --flake .#<host>`
- Home Manager only (if needed):
  - `home-manager switch --flake .#<host>`

## Documentation

- Host variable reference and config snippets: `docs/VARIABLES.md`
- `tcli` behavior, action mapping, and GC details: `docs/TCLI.md`
- sops key/secret setup: `docs/SOPS.md`
- adding and wiring a new host: `docs/NEW_HOST.md`

## Notes

- `hardware-configuration.nix` placeholders are overwritten by bootstrap.
- `tanvm` defaults disable bluetooth and use `graphics.profile = "vm"` for software-rendering reliability.
- `tanlappy` enables laptop defaults and leaves monitor layout on runtime discovery.
- This setup targets `nixpkgs-unstable`.
