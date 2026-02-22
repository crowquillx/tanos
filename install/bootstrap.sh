#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [host] [--update-hardware]

Options:
  --update-hardware  Also regenerate and overwrite hosts/<host>/hardware-configuration.nix
  -h, --help         Show this help
EOF
}

HOST="tanvm"
HOST_SET="false"
UPDATE_HARDWARE="false"

for arg in "$@"; do
  case "${arg}" in
    --update-hardware)
      UPDATE_HARDWARE="true"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: ${arg}"
      usage
      exit 1
      ;;
    *)
      if [[ "${HOST_SET}" == "true" ]]; then
        echo "Only one host may be provided."
        usage
        exit 1
      fi
      HOST="${arg}"
      HOST_SET="true"
      ;;
  esac
done
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST_DIR="${REPO_ROOT}/hosts/${HOST}"
HW_FILE="${HOST_DIR}/hardware-configuration.nix"
GENERATED_HW_FILE="${REPO_ROOT}/.local/hardware-configuration-${HOST}.nix"
KEY_FILE="/var/lib/sops-nix/key.txt"
NIX_EXPERIMENTAL_FEATURES="nix-command flakes"
FLAKE_REF="path:${REPO_ROOT}#${HOST}"

if [[ ! -d "${HOST_DIR}" ]]; then
  echo "Unknown host '${HOST}'. Expected one of: tandesk, tanvm."
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (or with sudo) so hardware config and rebuild can run."
  exit 1
fi

echo "Bootstrapping host: ${HOST}"
echo "Repo root: ${REPO_ROOT}"

# Keep bootstrap self-contained even when /etc/nix/nix.conf is immutable
# (common on NixOS where /etc is declaratively managed).
export NIX_CONFIG="${NIX_CONFIG-}"$'\n'"experimental-features = ${NIX_EXPERIMENTAL_FEATURES}"
echo "Using experimental features for this run: ${NIX_EXPERIMENTAL_FEATURES}"

if command -v nixos-generate-config >/dev/null 2>&1; then
  TMP_HW="$(mktemp)"
  nixos-generate-config --show-hardware-config > "${TMP_HW}"
  mkdir -p "$(dirname "${GENERATED_HW_FILE}")"
  cp "${TMP_HW}" "${GENERATED_HW_FILE}"
  echo "Updated runtime hardware config at ${GENERATED_HW_FILE}."
  if [[ -n "${SUDO_UID-}" ]] && [[ -n "${SUDO_GID-}" ]]; then
    chown "${SUDO_UID}:${SUDO_GID}" "${GENERATED_HW_FILE}"
  fi

  if [[ "${UPDATE_HARDWARE}" == "true" ]]; then
    cp "${TMP_HW}" "${HW_FILE}"
    echo "Updated tracked ${HW_FILE} from current machine."
    if [[ -n "${SUDO_UID-}" ]] && [[ -n "${SUDO_GID-}" ]]; then
      chown "${SUDO_UID}:${SUDO_GID}" "${HW_FILE}"
    fi
  else
    echo "Skipping tracked hardware config update. Use --update-hardware to regenerate ${HW_FILE}."
  fi

  rm -f "${TMP_HW}"
else
  echo "nixos-generate-config not found; keeping existing hardware config files."
fi

if [[ ! -f "${KEY_FILE}" ]]; then
  echo "Creating sops age key at ${KEY_FILE}"
  mkdir -p "$(dirname "${KEY_FILE}")"
  nix --extra-experimental-features "${NIX_EXPERIMENTAL_FEATURES}" \
    shell nixpkgs#age --command age-keygen -o "${KEY_FILE}"
  chmod 600 "${KEY_FILE}"
else
  echo "sops age key already exists at ${KEY_FILE}"
fi

echo "Running nixos-rebuild for ${HOST}"
cd "${REPO_ROOT}"
nixos-rebuild --extra-experimental-features "${NIX_EXPERIMENTAL_FEATURES}" \
  switch --flake "${FLAKE_REF}"

echo
echo "Bootstrap complete."
echo "Next:"
echo "1) Add encrypted secrets under ./secrets and update .sops.yaml recipients."
echo "2) Re-run: sudo nixos-rebuild switch --flake ${FLAKE_REF}"
