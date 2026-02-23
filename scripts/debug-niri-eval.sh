#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-tanlappy}"
USER_NAME="${2:-tan}"
FLAKE_REF="${3:-.}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/tanos-niri-debug-${HOST}-${USER_NAME}-${STAMP}.log"

run_eval() {
  local title="$1"
  shift
  echo "=== ${title} ==="
  nix --extra-experimental-features 'nix-command flakes' eval --show-trace "$@"
  echo
}

run_eval_raw() {
  local title="$1"
  shift
  echo "=== ${title} ==="
  nix --extra-experimental-features 'nix-command flakes' eval --show-trace --raw "$@"
  echo
}

run_eval_optional_raw() {
  local title="$1"
  shift
  echo "=== ${title} (optional) ==="
  if nix --extra-experimental-features 'nix-command flakes' eval --show-trace --raw "$@"; then
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
    "1) HM niri package option" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.home-manager.users.${USER_NAME}.wayland.windowManager.niri.package"

  run_eval_raw \
    "2) pkgs.niri pname" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.pkgs.niri.pname"

  run_eval_optional_raw \
    "3) pkgs.niriPackages.niri pname" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.pkgs.niriPackages.niri.pname"

  run_eval \
    "4) HM niri settings value" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.home-manager.users.${USER_NAME}.wayland.windowManager.niri.settings"

  run_eval_raw \
    "5) HM niri enable value" \
    "${FLAKE_REF}#nixosConfigurations.${HOST}.config.home-manager.users.${USER_NAME}.wayland.windowManager.niri.enable"
} 2>&1 | tee "${LOG_FILE}"

echo
echo "Saved log: ${LOG_FILE}"
