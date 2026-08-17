#!/usr/bin/env bash
# Remove linux-app-scale binaries and user units.
# Usage: uninstall-from-local.sh [--purge-config]
set -euo pipefail

BIN="${HOME}/.local/bin"
CFG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/linux-app-scale"
SYSTEMD_USER="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
LIB_DIR="${BIN}/linux-app-scale-lib"
PURGE_CONFIG=0

for arg in "$@"; do
  case "${arg}" in
    --purge-config) PURGE_CONFIG=1 ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--purge-config]"
      echo "  Removes binaries and user units. Keeps profiles unless --purge-config."
      echo "  Does not delete local .desktop files; run: app-scale remove --id ID first."
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 2
      ;;
  esac
done

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user disable --now app-scale-apply.path 2>/dev/null || true
  systemctl --user disable --now app-scale-apply.timer 2>/dev/null || true
  systemctl --user daemon-reload 2>/dev/null || true
fi

rm -f "${SYSTEMD_USER}/app-scale-apply.service"
rm -f "${SYSTEMD_USER}/app-scale-apply.timer"
rm -f "${SYSTEMD_USER}/app-scale-apply.path"
rm -f "${SYSTEMD_USER}/timers.target.wants/app-scale-apply.timer"
rm -f "${SYSTEMD_USER}/default.target.wants/app-scale-apply.path"
rm -f "${BIN}/app-scale" "${BIN}/app-scale-managed" "${BIN}/app-scale-apply" "${BIN}/verify-linux-app-scale"
rm -rf "${LIB_DIR}"

if [[ "${PURGE_CONFIG}" -eq 1 ]]; then
  rm -rf "${CFG_DIR}"
  echo "Removed config under ${CFG_DIR}."
else
  echo "Config kept at ${CFG_DIR} (delete manually or re-run with --purge-config)."
fi

echo "Removed app-scale binaries and user units."
