# Changelog

## Unreleased

## 0.1.0 — 2026-08-17

- Initial public extract: generic profile toolkit (`app-scale` / `app-scale-managed` / `app-scale-apply`).
- Toolkits: Chromium `--force-device-scale-factor` and Qt `QT_SCALE_FACTOR`.
- Discovery: `app-scale add --desktop PATH --toolkit chromium|qt --scale N`.
- Defaults: no apps wrapped, no ozone/X11, no seeded `DEVICE_SCALE_FACTOR`.
- systemd path unit watches vendor dirs only (not `~/.local/share/applications`).
- CI: `bash -n`, `ci-check.sh` (forbidden refs, safety defaults, tmp-HOME verify round-trip).
