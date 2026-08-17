# Example profiles

Copy one of these into `~/.config/linux-app-scale/profiles/` **after** `app-scale add`, or use them as a template when editing `EXTRA_FLAGS` / `EXTRA_ENV`. Nothing here is auto-installed.

**Try first:** `chromium-scale-only.conf.example` or `qt-scale-only.conf.example` (scale only).

If the app is still blurry, laggy, or has odd window chrome, open [docs/PLATFORM.md](../docs/PLATFORM.md) and pick **one** extra:

| File | When |
|------|------|
| `chromium-scale-only.conf.example` | Electron/Chrome-family; start here |
| `chromium-scale-x11.conf.example` | Still blurry under fractional scale |
| `chromium-wayland.conf.example` | Editor/IDE input path (native Wayland) |
| `qt-scale-only.conf.example` | Qt apps; start here |
| `qt-scale-xcb.conf.example` | Qt still ignores compositor scale |
| `split-stack.md` | Two Chromium apps: one X11+scale, one Wayland |
