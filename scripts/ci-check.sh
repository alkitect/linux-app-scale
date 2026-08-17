#!/usr/bin/env bash
# Release gate for linux-app-scale (local + CI).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

_p1='Python/'
_p2='Linux'
_p3='.cursor/plans'
_p4='topics/'
_p5='9070'
FORBIDDEN_RE="${_p1}${_p2}|${_p3}|${_p4}|${_p5}"

hits="$(grep -rE "${FORBIDDEN_RE}" \
  --include='*.sh' --include='*.py' --include='*.md' --include='*.config' --include='*.example' --include='*.desktop' . \
  --exclude-dir=.git --exclude-dir=__pycache__ \
  --exclude='ci-check.sh' 2>/dev/null || true)"
if [[ -n "${hits}" ]]; then
  echo "ci-check: forbidden path refs found:" >&2
  echo "${hits}" >&2
  exit 1
fi

REQUIRED_H2=(
  "## What this does"
  "## Who this is for"
  "## Quick start"
  "## Check it works"
  "## Uninstall"
  "## Limits & safety"
  "## License"
)
for h in "${REQUIRED_H2[@]}"; do
  grep -qFx "${h}" README.md || { echo "ci-check: README missing H2: ${h}" >&2; exit 1; }
done
if grep -qE '\bSSOT\b' README.md; then
  echo "ci-check: README must not use SSOT; say release source" >&2
  exit 1
fi

[[ -f .github/FUNDING.yml ]] || { echo "ci-check: missing .github/FUNDING.yml" >&2; exit 1; }
grep -qE '^[[:space:]]*ko_fi:[[:space:]]*alkitect[[:space:]]*$' .github/FUNDING.yml \
  || { echo "ci-check: .github/FUNDING.yml must set ko_fi: alkitect" >&2; exit 1; }
grep -qF 'ko-fi.com/alkitect' README.md \
  || { echo "ci-check: README must include Ko-fi tip link ko-fi.com/alkitect" >&2; exit 1; }
grep -qF 'ko-fi.com/img/githubbutton_sm.svg' README.md \
  || { echo "ci-check: README must include Ko-fi GitHub button (githubbutton_sm.svg)" >&2; exit 1; }
if grep -qiE 'patreon\.com|buymeacoffee\.com' README.md; then
  echo "ci-check: README must not link Patreon or Buy Me a Coffee" >&2
  exit 1
fi

if grep -qE '^[[:space:]]*DEVICE_SCALE_FACTOR=' config/example.config; then
  echo "ci-check: seeded example.config must not assign DEVICE_SCALE_FACTOR" >&2
  exit 1
fi
if grep -qF -- '--ozone-platform' config/example.config; then
  echo "ci-check: seeded example.config must not set --ozone-platform" >&2
  exit 1
fi
grep -q 'PathChanged=/var/lib/snapd/desktop/applications' systemd/user/app-scale-apply.path.example \
  || { echo "ci-check: path unit must watch snap vendor dir" >&2; exit 1; }
if grep -q '%h/.local/share/applications' systemd/user/app-scale-apply.path.example; then
  echo "ci-check: path unit must not watch local applications (apply loop)" >&2
  exit 1
fi

find scripts -type f \( -name '*.sh' -o -name 'app-scale' -o -name 'app-scale-managed' \) -print0 \
  | xargs -0 -r bash -n
python3 -m py_compile scripts/app-scale-apply

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
export HOME="${tmp}"
export XDG_CONFIG_HOME="${tmp}/.config"
export XDG_DATA_HOME="${tmp}/.local/share"
export XDG_STATE_HOME="${tmp}/.local/state"
export PATH="${tmp}/.local/bin:${PATH}"
"${ROOT}/scripts/install-to-local.sh"
test -x "${tmp}/.local/bin/app-scale"
test -x "${tmp}/.local/bin/app-scale-managed"
test -x "${tmp}/.local/bin/app-scale-apply"
test -x "${tmp}/.local/bin/verify-linux-app-scale"
test -f "${tmp}/.local/bin/linux-app-scale-lib/common.sh"
test -f "${tmp}/.config/linux-app-scale/config" \
  || { echo "ci-check: config not under tmp HOME (XDG isolation broken?)" >&2; exit 1; }
if grep -qE '^[[:space:]]*DEVICE_SCALE_FACTOR=' "${tmp}/.config/linux-app-scale/config"; then
  echo "ci-check: seeded user config assigned DEVICE_SCALE_FACTOR" >&2
  exit 1
fi

APP_SCALE_ROOT="${ROOT}" "${tmp}/.local/bin/verify-linux-app-scale"

"${ROOT}/scripts/uninstall-from-local.sh"
test ! -e "${tmp}/.local/bin/app-scale"
test ! -e "${tmp}/.local/bin/app-scale-managed"
test ! -e "${tmp}/.local/bin/app-scale-apply"
test ! -e "${tmp}/.local/bin/verify-linux-app-scale"
test ! -e "${tmp}/.local/bin/linux-app-scale-lib"
test -f "${tmp}/.config/linux-app-scale/config"

# Versioning gate (alkitect public extracts)
if [[ -f docs/PUBLISH.md ]] && grep -qF 'RC-BEFORE-1.0' docs/PUBLISH.md; then
  :
else
  if [[ -f CHANGELOG.md ]] && grep -qE '^## 0\.9\.0' CHANGELOG.md; then
    echo "ci-check: CHANGELOG ## 0.9.0 is not the default first tag; add RC-BEFORE-1.0 to docs/PUBLISH.md or use 0.1.0+" >&2
    exit 1
  fi
  for _vf in docs/PUBLISH.md README.md; do
    if [[ -f "${_vf}" ]] && grep -qE 'v0\.9\.0' "${_vf}"; then
      echo "ci-check: ${_vf} mentions v0.9.0 without RC-BEFORE-1.0" >&2
      exit 1
    fi
  done
fi
if grep -rE '/home/alex' --include='*.md' . --exclude-dir=.git >/dev/null 2>&1; then
  echo "ci-check: public markdown must not contain /home/alex host paths" >&2
  grep -rE '/home/alex' --include='*.md' . --exclude-dir=.git >&2 || true
  exit 1
fi
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    && git describe --tags --abbrev=0 >/dev/null 2>&1; then
  _tag="$(git describe --tags --abbrev=0)"
  _tag="${_tag#v}"
  _first="$(awk '/^## [0-9]+\.[0-9]+\.[0-9]+/{ sub(/^## /,""); sub(/ .*/,""); print; exit }' CHANGELOG.md)"
  if [[ -n "${_first}" && "${_first}" != "${_tag}" ]]; then
    echo "ci-check: CHANGELOG first dated section ${_first} != git describe ${_tag}" >&2
    exit 1
  fi
fi

echo "ci-check: OK"
