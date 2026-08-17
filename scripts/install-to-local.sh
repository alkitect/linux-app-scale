#!/usr/bin/env bash
# Install app-scale binaries, seed global config, deploy systemd user units.
# Usage: install-to-local.sh [--enable-automation]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${HOME}/.local/bin"
CFG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/linux-app-scale"
LIB_DIR="${BIN}/linux-app-scale-lib"
SYSTEMD_USER="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
ENABLE_AUTOMATION=0

for arg in "$@"; do
  case "${arg}" in
    --enable-automation) ENABLE_AUTOMATION=1 ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--enable-automation]"
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 2
      ;;
  esac
done

mkdir -p "${BIN}" "${CFG_DIR}/profiles" "${LIB_DIR}" "${SYSTEMD_USER}"
install -m0755 "${ROOT}/scripts/app-scale" "${BIN}/app-scale"
install -m0755 "${ROOT}/scripts/app-scale-managed" "${BIN}/app-scale-managed"
install -m0755 "${ROOT}/scripts/app-scale-apply" "${BIN}/app-scale-apply"
install -m0755 "${ROOT}/scripts/verify-linux-app-scale.sh" "${BIN}/verify-linux-app-scale"
install -m0644 "${ROOT}/scripts/lib/common.sh" "${LIB_DIR}/common.sh"

if [[ ! -f "${CFG_DIR}/config" ]]; then
  install -m0644 "${ROOT}/config/example.config" "${CFG_DIR}/config"
  echo "Seeded ${CFG_DIR}/config"
else
  echo "Keeping existing ${CFG_DIR}/config"
fi

for unit in service timer path; do
  src="${ROOT}/systemd/user/app-scale-apply.${unit}.example"
  dest="${SYSTEMD_USER}/app-scale-apply.${unit}"
  install -m0644 "${src}" "${dest}"
  echo "Installed systemd user unit: ${dest}"
done

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
fi

echo ""
echo "Installed:"
echo "  ${BIN}/app-scale"
echo "  ${BIN}/app-scale-managed"
echo "  ${BIN}/app-scale-apply"
echo "  ${BIN}/verify-linux-app-scale"
echo ""
echo "No apps are wrapped until you run: app-scale add --desktop PATH --toolkit chromium|qt --scale N"
echo ""
echo "Enable automation (vendor .desktop watch + backup timer):"
echo "  systemctl --user enable --now app-scale-apply.path"
echo "  systemctl --user enable --now app-scale-apply.timer"

if [[ "${ENABLE_AUTOMATION}" -eq 1 ]]; then
  echo ""
  echo "Enabling automation (--enable-automation)..."
  systemctl --user enable --now app-scale-apply.path
  systemctl --user enable --now app-scale-apply.timer
  echo "Automation enabled."
fi
