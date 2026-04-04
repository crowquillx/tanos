# Parts-wrapped implementation (Vimjoyer-style)

This repository now follows a **Vimjoyer-style parts-wrapped flake layout**:

- guide used: <https://www.vimjoyer.com/vid79-parts-wrapped>
- module auto-loading: <https://github.com/vic/import-tree>
- flake module framework: <https://flake.parts/>

## Core design

## 1) `flake.nix` stays tiny

`flake.nix` now does three things only:

1. declare inputs
2. bootstrap `flake-parts`
3. auto-import `modules/flake` with `import-tree`

This closely follows the video pattern (`mkFlake ... (import-tree ./modules)`).

## 2) Flake logic lives in `modules/flake/`

- `modules/flake/hosts.nix`
  - defines host map (`hostPlatforms`)
  - publishes `flake.nixosModules.<host>` and `flake.homeModules.<user>`
  - builds `nixosConfigurations`, `ciNixosConfigurations`, `homeConfigurations`
- `modules/flake/packages.nix`
  - defines `perSystem.packages` for wrapped/custom packages
  - includes wrapped + upstream package outputs (`tanos-niri`, `tanos-noctalia`, `tanos-zen`, `tanos-helium`)

## 3) Shared NixOS + Home stack wiring

`modules/combined/stacks.nix` is the single source for shared module composition:

- `nixosModules`: imported by `hosts/common/default.nix`
- `homeModules`: imported by `users/tan/home.nix`

`combined` is passed through special args from `modules/flake/hosts.nix` into both system and home evaluation paths.

## Simplified file layout

```text
.
├── flake.nix
├── modules
│   ├── flake
│   │   ├── hosts.nix
│   │   └── packages.nix
│   ├── combined
│   │   └── stacks.nix
│   ├── nixos
│   └── home
├── hosts
└── users
```

## Initial installation

1. Clone repository.
2. Select host (`tandesk`, `tanvm`, `tanlappy`).
3. Run bootstrap:
   - `sudo ./install/bootstrap.sh <host>`
4. Reboot and log in via SDDM.

## Updates and day-to-day operations

Recommended:

- `tcli rebuild build <host>`
- `tcli rebuild switch <host>`
- `tcli update <host>`

Fallback:

- `sudo nixos-rebuild build --flake .#<host>`
- `sudo nixos-rebuild switch --flake .#<host>`
- `home-manager switch --flake .#<host>`

## Contributor patterns

### Add a new host

1. Create `hosts/<newhost>/` files.
2. Register `<newhost>` in `modules/flake/hosts.nix` (`hostPlatforms` + `flake.nixosModules`).
3. Build with `tcli rebuild build <newhost>`.

### Add/modify shared feature modules

1. Update paths in `modules/combined/stacks.nix`.
2. Keep NixOS/Home pairs aligned by feature domain.
3. Build affected host(s).

### Add package outputs (wrapped/custom)

1. Edit `modules/flake/packages.nix`.
2. Add package under `perSystem.packages`.
3. Consume from modules or `nix run .#<package-name>`.

## Notes

- KDE + Niri remain fully supported; this refactor changes structure/composition, not desktop feature intent.
- If lockfile updates are required for new inputs, run `nix flake lock --update-input <name>` in a Nix-enabled environment.
