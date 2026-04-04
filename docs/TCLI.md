# tcli

`tcli` is a Home Manager-installed helper command for this repository.

It provides one place to run common flake lifecycle tasks while handling both layers through one NixOS rebuild path (Home Manager via NixOS integration).

The default rebuild path now runs through `nh`, so you get the tree view, diffs, and related `nh` UX without changing the repo's host/home composition model.

## Commands

### `tcli`

- Equivalent to: `tcli switch`
- Defaults to current machine hostname
- Runs:
  - `nh os switch <repo> -H <host>`

### `tcli [switch|build|test|boot] [host] [-- <nh-args...>]`

- Default host: current machine hostname
- Runs a single `nh` command:
  - `nh os <action> <repo> -H <host> [nh args...]`

Home Manager is applied through the NixOS `home-manager` module (`home-manager.users`), so this remains a full system+home workflow without a second standalone `home-manager` invocation.

### `tcli rebuild [switch|build|test|boot] [host]`

- Backward-compatible alias for `tcli [switch|build|test|boot] [host]`

### `tcli update [host]` / `tcli upgrade [host] [-- <nh-args...>]`

- Defaults to current machine hostname
- Runs:
  - `nh os switch <repo> -H <host> --update [nh args...]`

This still uses one rebuild invocation and keeps Home Manager on the NixOS-integrated path.

### `tcli gc [-- <nh-args...>]`

Runs:

- `nh clean all [nh args...]`

### `tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]`

- Default action: `switch`
- Default host: current machine hostname
- Runs:
  - `nh os <action> <repo> -H <host> [nh args...]`

### `tcli nh home [switch|build] [host] [-- <nh-args...>]`

- Default action: `switch`
- Default host: current machine hostname
- Runs:
  - `nh home <action> <repo> -c <host> [nh args...]`

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
4. `$HOME/tanos`

## Aliases

Shell aliases are set by Home Manager (bash + fish):

- `fu` -> `tcli update`
- `fr` -> `tcli`
- `ncg` -> `tcli gc`

## Bootstrap integration

`install/bootstrap.sh` still explicitly runs both:

1. `nixos-rebuild`
2. Home Manager activation package (`homeConfigurations.<host>.activationPackage`)

So bootstrap and `tcli` both enforce full system + HM activation, but via different command paths.
