#!/usr/bin/env bash
# Verify linux-app-scale scripts and a tmp-HOME add/apply/remove round-trip.
set -euo pipefail

ROOT="${APP_SCALE_ROOT:-}"
if [[ -z "$ROOT" ]]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "${here}/../scripts/app-scale-apply" ]]; then
    ROOT="$(cd "${here}/.." && pwd)"
  elif [[ -f "${here}/app-scale-apply" && -f "${here}/../fixtures/fixture-chromium.desktop" ]]; then
    ROOT="$(cd "${here}/.." && pwd)"
  fi
fi
if [[ -z "${ROOT}" || ! -f "${ROOT}/scripts/app-scale-apply" ]]; then
  echo "verify: set APP_SCALE_ROOT to the linux-app-scale checkout" >&2
  exit 2
fi

fail() { echo "verify: FAIL: $*" >&2; exit 1; }
ok() { echo "verify: OK: $*"; }

find "${ROOT}/scripts" -type f -name '*.sh' -print0 | xargs -0 -r bash -n
python3 -m py_compile "${ROOT}/scripts/app-scale-apply"
ok "syntax"

BIN="${HOME}/.local/bin"
if [[ ! -x "${BIN}/app-scale" ]]; then
  echo "verify: app-scale not installed under ${BIN}; run ./scripts/install-to-local.sh" >&2
  exit 1
fi

export PATH="${BIN}:${PATH}"

work="$(mktemp -d "${TMPDIR:-/tmp}/app-scale-verify.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT
cp "${ROOT}/fixtures/fixture-chromium.desktop" "${work}/fixture-chromium.desktop"
cp "${ROOT}/fixtures/fixture-qt.desktop" "${work}/fixture-qt.desktop"

app-scale add --desktop "${work}/fixture-chromium.desktop" --toolkit chromium --id fixture-chromium --scale 1.25
app-scale add --desktop "${work}/fixture-qt.desktop" --toolkit qt --id fixture-qt --scale 1.25

apps="${XDG_DATA_HOME:-${HOME}/.local/share}/applications"
local_c="${apps}/fixture-chromium.desktop"
local_q="${apps}/fixture-qt.desktop"
[[ -f "$local_c" ]] || fail "missing local chromium desktop"
[[ -f "$local_q" ]] || fail "missing local qt desktop"

grep -q "app-scale-managed fixture-chromium /usr/bin/true" "$local_c" || fail "chromium Exec not wrapped"
grep -q "%U" "$local_c" || fail "chromium field code %U was dropped"
grep -q "app-scale-managed fixture-qt /usr/bin/true" "$local_q" || fail "qt Exec not wrapped"
grep -q "^X-LinuxAppScale=fixture-chromium$" "$local_c" || fail "missing X-LinuxAppScale marker"

app-scale apply --check
ok "apply --check satisfied"

if app-scale add --desktop "${work}/fixture-chromium.desktop" --toolkit gtk --id should-fail --scale 1.25 2>/dev/null; then
  fail "gtk toolkit should be refused"
fi
ok "gtk refused"

app-scale remove --id fixture-chromium --purge-config
app-scale remove --id fixture-qt --purge-config
[[ ! -f "$local_c" ]] || fail "chromium local desktop still present"
[[ ! -f "$local_q" ]] || fail "qt local desktop still present"
ok "remove"

echo "verify: all checks passed"
