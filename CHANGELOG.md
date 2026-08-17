# Changelog

## Unreleased

## 0.1.1 — 2026-08-17

- Reconciler wraps only `[Desktop Entry]` `Exec=` (skip Desktop Actions).
- `add` refuses a second profile on the same `LOCAL_DESKTOP`.
- Verify: Flatpak, nested `*-managed`, missing `--scale`, Desktop Action skip.
- Examples index; README: relaunch from Activities; do not stack with per-app wrappers.
- CI: `ci-check.sh` only; assert no seeded profiles; uninstall removes user units.

## 0.1.0 — 2026-08-17

- Initial public extract: generic profile toolkit (`app-scale` / `app-scale-managed` / `app-scale-apply`).
- Toolkits: Chromium `--force-device-scale-factor` and Qt `QT_SCALE_FACTOR`.
- Discovery: `app-scale add --desktop PATH --toolkit chromium|qt --scale N`.
- Defaults: no apps wrapped, no ozone/X11, no seeded `DEVICE_SCALE_FACTOR`.
- systemd path unit watches vendor dirs only (not `~/.local/share/applications`).
- CI: `bash -n`, `ci-check.sh` (forbidden refs, safety defaults, tmp-HOME verify round-trip).
