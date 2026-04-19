# tanos

Minimal multi-host NixOS flake with Home Manager, `nixpkgs-unstable`, Niri via `sodiboo/niri-flake`, Noctalia shell, SDDM, Stylix (Rose Pine), fish + starship, NH, and `sops-nix`.

## Hosts

- `tandesk`: physical machine profile
- `tanvm`: VM-first profile (QEMU/KVM + virtio defaults, software-rendering fallback enabled)
- `tanlappy`: laptop profile (power/lid/battery defaults enabled)

All hosts currently use username `tan`.

## Layout

- `flake.nix`: parts-wrapped flake entrypoint (via `flake-parts`)
- `modules/flake/*`: parts-wrapped flake modules (host registry, external module injection, packages, output assembly)
- `modules/combined/stacks.nix`: repo-owned shared stack wiring for both NixOS + Home Manager modules
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
4. Reboot and log in through SDDM (Niri session).

## tcli

`tcli` is installed via Home Manager and is the recommended day-to-day command for this repo.

It handles both system + Home Manager through one rebuild path, now backed by `nh` for the rebuild UX:

1. NixOS rebuild (`nh os`)
2. Home Manager activation via NixOS `home-manager` module integration

`bootstrap.sh` and `tcli nh home` still use `homeConfigurations.<host>`, but that path now reuses the same published user entrypoint as the integrated `home-manager.users` path.

Commands:

- `tcli` (defaults to `switch` on the current host)
- `tcli [switch|build|test|boot] [host] [-- <nh-args...>]`
- `tcli rebuild [switch|build|test|boot] [host]`
- `tcli update [host] [-- <nh-args...>]` (alias: `tcli upgrade [host]`)
- `tcli gc [-- <nh-args...>]`
- `tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]`
- `tcli nh home [switch|build] [host] [-- <nh-args...>]`
- `tcli nh clean [-- <nh-args...>]`

Defaults:

- host defaults to current machine hostname
- flake path defaults to current repo root (or `TANOS_FLAKE_DIR`)

Short aliases (bash + fish):

- `fu` -> `tcli update`
- `fr` -> `tcli`
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

## Installing New Apps

Most user-facing apps in this repo should be installed through Home Manager by adding package names to the host's `users.extraPackages` list in `hosts/<host>/variables.nix`.

Example:

```nix
users = {
  primary = "tan";
  extraPackages = [
    "obsidian"
    "mpv"
    "python3Packages.ipython"
  ];
};
```

Notes:

- Package names are resolved from `pkgs`, so nested attributes such as `"python3Packages.ipython"` work.
- If a package name is wrong, evaluation fails with an `Unknown users.extraPackages entries` assertion.
- After editing, apply the change with `tcli rebuild switch <host>` or test it first with `tcli rebuild build <host>`.

If an app is not available in `nixpkgs`, you can manage it declaratively with Flatpak in `hosts/<host>/variables.nix`:

```nix
features.flatpak = {
  enable = true;
  packages = [
    "com.spotify.Client"
    "md.obsidian.Obsidian"
  ];
};
```

Behavior:

- Declared entries in `features.flatpak.packages` are installed declaratively via `nix-flatpak`.
- If you remove an entry from that list later, the next rebuild removes unmanaged system Flatpaks so the declared set stays authoritative.
- Unrelated manually-installed Flatpaks are left alone.

If you prefer a one-off manual install instead, enable Flatpak and then run `flatpak install flathub <app-id>`.

If you want an installed app to launch automatically in your session, add its command to `desktop.startup.apps`. This does not install the app by itself; it only autostarts an already-available command.

```nix
desktop.startup.apps = [
  "spotify"
  "equibop"
];
```

## Documentation

- Host variable reference and config snippets: `docs/VARIABLES.md`
- `tcli` behavior, action mapping, and GC details: `docs/TCLI.md`
- sops key/secret setup: `docs/SOPS.md`
- adding and wiring a new host: `docs/NEW_HOST.md`
- parts-wrapped architecture and migration notes: `docs/DENDRITIC.md`
- secure boot setup (lanzaboote + microsoft keys): `docs/SECURE_BOOT.md`

## Notes

- `hardware-configuration.nix` placeholders are overwritten by bootstrap.
- Standalone and NixOS-integrated Home Manager paths now share the same `flake.homeModules.<user>` entrypoint, which keeps bootstrap, `tcli nh home`, and normal rebuilds aligned.
- `tanvm` defaults disable bluetooth and use `graphics.profile = "vm"` for software-rendering reliability.
- `tanlappy` enables laptop defaults and leaves Niri output layout ready to define in `hosts/tanlappy/variables.nix`.
- This setup targets `nixpkgs-unstable`.
- Secure Boot support:
  - Controlled per host via `boot.secureBoot.*` in `hosts/<host>/variables.nix`.
  - Defaults to disabled (`enable = false`) with Microsoft keys supported when enabled.
  - Follow `docs/SECURE_BOOT.md` **before** enabling in firmware.
- Niri package setup:
  - The system uses `pkgs.niri-unstable` from `inputs.niri.overlays.niri`, matching Sodiboo's docs for using the overlay with your system `nixpkgs`.
  - The NixOS module keeps `niri-flake.cache.enable = true`, so `niri.cachix.org` is used by default.
  - Per-host monitor layout lives under `desktop.niri.outputs` in `hosts/<host>/variables.nix`.
- Noctalia setup:
  - Noctalia is managed through Home Manager with `programs.noctalia-shell.systemd.enable = true`.
  - Per-host Noctalia settings live under `desktop.noctalia` in `hosts/<host>/variables.nix`.
