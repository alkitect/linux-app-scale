# Platform options (X11, Wayland, Qt)

linux-app-scale’s **default** is scale only: Chromium `--force-device-scale-factor` or Qt `QT_SCALE_FACTOR`. Extra platform flags are **opt-in** per profile (`EXTRA_FLAGS` / `EXTRA_ENV`).

Copy a file from [examples/profiles/](../examples/profiles/) into `~/.config/linux-app-scale/profiles/` only after you understand the tradeoff. Do not enable ozone or xcb on every app.

## Terms

| Term | Meaning |
|------|---------|
| **X11** | Display protocol. |
| **XCB** | A library that speaks X11 (Qt `QT_QPA_PLATFORM=xcb`). Not a second display server. |
| **`--ozone-platform=x11`** | Chromium/Electron X11 backend. On a Wayland session this is almost always **XWayland**. |
| **Native Wayland** | `--ozone-platform=wayland` — the app talks to the compositor without XWayland. |

You are choosing **X11-via-XWayland** vs **native Wayland**, not a separate “XCB performance knob”.

## Pick by problem

### 1. Blurry Chromium under GNOME fractional scale

**Try first:** scale only (`examples/profiles/chromium-scale-only.conf.example`).

If the UI is still a smeared bitmap, many Electron apps render sharply only as XWayland clients:

```text
EXTRA_FLAGS=--ozone-platform=x11
SCALE=1.25
```

Match `SCALE` to the size you want (often the same as the session’s 125%/150%).

**Anti-pattern:** native Wayland **and** `--force-device-scale-factor` on a session that is already 100% sharp — Chromium can draw a tiny UI with broken resize. If that happens, drop the scale flag or stay on X11 ozone for that app only.

### 2. Input lag with several Chromium apps on XWayland

Putting **every** heavy Electron app on `--ozone-platform=x11` can add lag (extra path: app → XWayland → compositor).

**Split stack:** keep the scale-critical app on X11 ozone; keep the editor/IDE on native Wayland.

Worked example that was validated on GNOME Wayland: **Brave** (browser) on X11 + scale for sharpness; **Cursor** (Electron editor) on `--ozone-platform=wayland` for typing. This tool does not ship a Cursor profile; set `EXTRA_FLAGS` on whatever two profiles you add. See [split-stack.md](../examples/profiles/split-stack.md).

Do **not** move a blur-fixed browser to native Wayland just to “match” the editor if that reintroduces blur or the tiny-UI anti-pattern above.

### 3. Electron window chrome (CSD / missing shadow)

Newer Electron on Wayland may draw client-side decorations (rounded chrome, different shadow). Options:

- `--ozone-platform=wayland` and accept compositor/client decorations
- `--ozone-platform=x11` so the window looks like other XWayland apps
- An **app setting** such as a native title bar — this tool does not write editor JSON

### 4. Qt looks wrong (Telegram-class)

Default Qt profile is env scale only. If the toolkit still ignores the compositor, try:

```text
EXTRA_ENV=GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb
```

Leave this commented until you need it (`examples/profiles/qt-scale-xcb.conf.example`).

### 5. GPU flags

Chromium already enables GPU compositing when the driver is not blocklisted. Do **not** add `--enable-gpu` by default. `--disable-gpu` forces software rendering. `--ignore-gpu-blocklist` can help or destabilize — test one app at a time via `EXTRA_FLAGS`.

## How to apply an extra

1. `app-scale show --id ID`
2. Edit `EXTRA_FLAGS=` or `EXTRA_ENV=` in that profile
3. `app-scale apply --id ID`
4. Fully quit the app; launch from Applications
5. Confirm the flag: `pgrep -af your-binary` and, for XWayland, `xlsclients`

## What this file is not

- Not a GDM/login-scale guide
- Not a promise that Cursor, Brave, or any named app is a supported product SKU
- Not a recommendation to force X11 on a whole desktop session
