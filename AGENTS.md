# Repository Guidelines

## Project Structure & Module Organization
This repository is a multi-host NixOS flake with Home Manager integration.

- `flake.nix`: output wiring for `nixosConfigurations` and `homeConfigurations`.
- `hosts/<host>/`: host-specific `default.nix`, `variables.nix`, and `hardware-configuration.nix`.
- `hosts/common/`: shared host defaults and schema.
- `modules/nixos/`: system modules (services, desktop, profiles, security, shells).
- `modules/home/`: Home Manager modules (base, desktop, theme, terminals).
- `users/tan/home.nix`: user entrypoint imported by Home Manager.
- `install/bootstrap.sh`: initial provisioning workflow.
- `docs/`: operational guides (`VARIABLES.md`, `TCLI.md`, `NEW_HOST.md`, `SOPS.md`).

## Build, Test, and Development Commands
Use `tcli` for day-to-day work (recommended):

- `tcli rebuild switch <host>`: rebuild and activate both NixOS + Home Manager.
- `tcli rebuild build <host>`: build only, no activation.
- `tcli update <host>`: update flake inputs, then rebuild.
- `sudo ./install/bootstrap.sh <host>`: first-time bootstrap on a machine.

Direct commands (fallback):

- `sudo nixos-rebuild switch --flake .#<host>`
- `home-manager switch --flake .#<host>`
- `statix check .` (lint)

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and semicolon-terminated assignments.
- Keep modules focused by domain (`services/`, `desktop/`, `theme/`, etc.).
- Prefer descriptive, host-scoped toggles in `hosts/<host>/variables.nix`.
- Use lowercase kebab-case for module filenames (for example, `session-runtime.nix`).

## Testing Guidelines
There is no dedicated unit-test suite; validation is build/eval based.

- Run `statix check .` before opening a PR.
- Run `tcli rebuild build <host>` for affected hosts.
- For runtime-impacting changes, run `tcli rebuild switch <host>` and verify session/services.

## Commit & Pull Request Guidelines
Recent history favors short imperative commits, often with `fix:` prefixes.

- Commit format: concise subject, one logical change per commit.
- Include scope when useful (example: `fix: niri-user config merge structure`).
- PRs should include: summary, affected hosts/modules, validation commands run, and screenshots for UI/session changes.

## Security & Configuration Tips
- Never commit plaintext secrets; use `sops-nix` and `secrets/<host>.yaml`.
- Keep `hardware-configuration.nix` host-specific and generated from target hardware.
