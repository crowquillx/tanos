# tcli

`tcli` is a Home Manager-installed helper command for this repository.

It provides one place to run common flake lifecycle tasks while always handling both layers:

1. NixOS system modules
2. Home Manager modules

## Commands

### `tcli rebuild [switch|build|test|boot] [host]`

- Default action: `switch`
- Default host: current machine hostname
- Runs:
  - `sudo nixos-rebuild <action> --flake path:<repo>#<host>`
  - `home-manager <mapped-action> --flake path:<repo>#<host>`

Action mapping for Home Manager:

- `switch` -> `switch`
- `build` -> `build`
- `test` -> `switch` (HM has no `test` action)
- `boot` -> `build` (HM has no `boot` action)

### `tcli update [host]`

- Runs `nix flake update --flake path:<repo>`
- Then runs `tcli rebuild switch [host]`

### `tcli gc`

Runs garbage collection for both system and user-side generations:

- `sudo nix-collect-garbage -d`
- remove old Home Manager generations from `/nix/var/nix/profiles/per-user/$USER/home-manager`
- `nix-collect-garbage -d`

### `tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]`

- Default action: `switch`
- Default host: current machine hostname
- Runs:
  - `nh os <action> path:<repo>#<host> [nh args...]`

### `tcli nh home [switch|build] [host] [-- <nh-args...>]`

- Default action: `switch`
- Default host: current machine hostname
- Runs:
  - `nh home <action> path:<repo>#<host> [nh args...]`

### `tcli nh clean [-- <nh-args...>]`

- Runs:
  - `nh clean all [nh args...]`

## Resolution rules

### Host resolution

- If host is passed, use it
- Otherwise use `/etc/hostname` (or `hostname` fallback)
- Host must exist under `hosts/<host>`

### Flake path resolution

`tcli` finds the repo in this order:

1. `TANOS_FLAKE_DIR` environment variable
2. current git root (if it has `flake.nix`)
3. current directory (if it has `flake.nix`)
4. `$HOME/REPOS/tanos`

## Aliases

Shell aliases are set by Home Manager (bash + fish):

- `fu` -> `tcli update`
- `fr` -> `tcli rebuild`
- `ncg` -> `tcli gc`

## Bootstrap integration

`install/bootstrap.sh` now explicitly runs both:

1. `nixos-rebuild`
2. Home Manager activation package (`homeConfigurations.<host>.activationPackage`)

So bootstrap and `tcli` both enforce full system + HM activation.
