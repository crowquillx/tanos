#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-tanlappy}"
USER_NAME="${2:-tan}"
FLAKE_REF="${3:-.}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/tanos-hyprland-debug-${HOST}-${USER_NAME}-${STAMP}.log"

run_eval() {
  local title="$1"
  shift
  echo "=== ${title} ==="
  nix --extra-experimental-features 'nix-command flakes' eval --accept-flake-config --show-trace "$@"
  echo
}

run_eval_raw() {
  local title="$1"
  shift
  echo "=== ${title} ==="
  nix --extra-experimental-features 'nix-command flakes' eval --accept-flake-config --show-trace --raw "$@"
  echo
}

run_eval_optional() {
  local title="$1"
  shift
  echo "=== ${title} (optional) ==="
  if nix --extra-experimental-features 'nix-command flakes' eval --accept-flake-config --show-trace "$@"; then
    :
  else
    echo "optional check failed; continuing"
  fi
  echo
}

run_eval_optional_raw() {
  local title="$1"
  shift
  echo "=== ${title} (optional) ==="
  if nix --extra-experimental-features 'nix-command flakes' eval --accept-flake-config --show-trace --raw "$@"; then
    :
  else
    echo "optional check failed; continuing"
  fi
  echo
}

{
  echo "Debug started: $(date --iso-8601=seconds)"
  echo "Host: ${HOST}"
  echo "User: ${USER_NAME}"
  echo "Flake: ${FLAKE_REF}"
  echo

  run_eval \
    "1) HM hyprland package option (nixosConfigurations path)" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.home-manager.users.${USER_NAME}.wayland.windowManager.hyprland.package"

  run_eval_optional \
    "2) HM hyprland enable value (nixosConfigurations path)" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.home-manager.users.${USER_NAME}.wayland.windowManager.hyprland.enable"

  run_eval \
    "3) HM hyprland package option (homeConfigurations path)" \
    "${FLAKE_REF}#homeConfigurations.${HOST}.config.wayland.windowManager.hyprland.package"

  run_eval_optional \
    "4) HM hyprland enable value (homeConfigurations path)" \
    "${FLAKE_REF}#homeConfigurations.${HOST}.config.wayland.windowManager.hyprland.enable"

  run_eval_raw \
    "5) NixOS programs.hyprland.package drvPath" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.programs.hyprland.package.drvPath"

  run_eval_optional \
    "6) NixOS displayManager defaultSession" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.services.displayManager.defaultSession"

  run_eval_optional_raw \
    "7) Home session XDG_CURRENT_DESKTOP" \
    "${FLAKE_REF}#homeConfigurations.${HOST}.config.home.sessionVariables.XDG_CURRENT_DESKTOP"

  run_eval_optional_raw \
    "8) Home session ILLOGICAL_IMPULSE_VIRTUAL_ENV" \
    "${FLAKE_REF}#homeConfigurations.${HOST}.config.home.sessionVariables.ILLOGICAL_IMPULSE_VIRTUAL_ENV"

  run_eval_optional \
    "9) Illogical module enable value (homeConfigurations path)" \
    "${FLAKE_REF}#homeConfigurations.${HOST}.config.programs.illogical-impulse.enable"
} 2>&1 | tee "${LOG_FILE}"

echo
echo "Saved log: ${LOG_FILE}"
