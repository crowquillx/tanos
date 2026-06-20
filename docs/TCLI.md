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

### `tcli check`

Runs three pre-build validation checks:

1. **statix check** — Nix lint on the flake directory.
2. **Orphan module scan** — finds `.nix` files under `modules/nixos` and `modules/home` that are not referenced by any other `.nix` file (not in `stacks.nix`, not imported by a parent). Catches modules that exist but were never wired into the module stack.
3. **nix flake check --no-build** — eval-only flake validation.

Exits non-zero if any check fails. Safe to run before any build or switch.

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

## Hardening features

### Uncommitted-state guard (`switch`, `boot`, `test`, `update`)

Before activating a system, `tcli` checks `git status --porcelain`. If the working tree has uncommitted changes, it prints a warning listing the dirty files and prompts for confirmation. This prevents activating a system built from state that could be lost, leaving future rebuilds with a different closure.

### Closure-diff service summarizer (`build`, `switch`, `test`)

After a successful build or activation, `tcli` runs `nix store diff-closures` between the old and new system and prints a focused summary of:
- Closure size change
- Added/removed systemd units (`unit-*.service`, `unit-*.socket`, `unit-*.timer`, `unit-*.target`)

This makes unexpected service removals immediately visible instead of buried in the full `nh` diff table.

### Git build context

Before every `nh os` invocation, `tcli` prints the current git HEAD sha and uncommitted-file count, so you can see exactly what state the system is being built from.

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
Both paths consume the same published user module entrypoint from `flake.homeModules`.
