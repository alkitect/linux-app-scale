# linux-app-scale

Per-app HiDPI scale for Linux launchers that survives snap and deb desktop refreshes.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/alkitect)

## What this does

GNOME fractional scaling often leaves Electron and Qt apps **blurry**. Forcing the whole session to 100% makes those apps sharp but tiny; per-app scale flags fix one app without changing Mutter.

This tool wraps a `.desktop` `Exec=` line so the dock and app grid launch `app-scale-managed`, which injects Chromium `--force-device-scale-factor` or Qt `QT_SCALE_FACTOR`. A reconciler copies the vendor launcher back after a snap or package refresh.

**Safe by default:** install wraps **no** apps and adds **no** X11/ozone flags. You choose a toolkit, a scale, and (optionally) platform extras per profile.

## Who this is for

- **In:** Ubuntu / GNOME (other XDG desktops usually work) with HiDPI or fractional scale.
- **In:** Snap or `.deb` apps whose `.desktop` file you can point at (`--desktop PATH`).
- **Not for:** GDM/login scaling, Flatpak (`flatpak run`), GTK-only apps, or changing GNOME’s session scale.

## Quick start

```bash
git clone https://github.com/alkitect/linux-app-scale.git
cd linux-app-scale
./scripts/install-to-local.sh
app-scale add --desktop /var/lib/snapd/desktop/applications/signal-desktop_signal-desktop.desktop \
  --toolkit chromium --scale 1.25
```

Replace the `.desktop` path and toolkit with **your** app (`chromium` for Electron/Chrome-family, `qt` for Qt). Pick `--scale` to match the size you want (common values: `1.25`, `1.5`, `2.0`).

**What you installed:** `app-scale`, `app-scale-managed`, and `app-scale-apply` in `~/.local/bin`, plus a seeded `~/.config/linux-app-scale/config` that does not wrap anything. Optional systemd path + timer: `./scripts/install-to-local.sh --enable-automation`.

**Stay safe before enabling automation:** add one app, fully quit it, launch from Applications, then enable the path unit. Platform flags (X11 ozone, Qt xcb) stay off unless you copy them from [docs/PLATFORM.md](docs/PLATFORM.md).

**Needs:** `bash`, `python3`, write access to `~/.local`, and a session that honors `~/.local/share/applications/` (GNOME does).

## Check it works

You want `apply --check` clean and the local `.desktop` `Exec=` pointing at `app-scale-managed`.

```bash
APP_SCALE_ROOT="$PWD" ./scripts/verify-linux-app-scale.sh
app-scale list
app-scale apply --dry-run
```

- If the app still looks blurry: quit it fully and launch from the dock, not a terminal alias. See **Configure**.
- If scale is wrong: `app-scale show --id ID`, edit `SCALE=`, then `app-scale apply --id ID`.

Maintainers: `./scripts/ci-check.sh`.

## Uninstall

```bash
app-scale remove --id ID --purge-config   # one app; GNOME falls back to the vendor launcher
./scripts/uninstall-from-local.sh
# also remove remaining profiles:
./scripts/uninstall-from-local.sh --purge-config
```

## Configure

- **Scale:** `--scale` on add, or `SCALE=` in `~/.config/linux-app-scale/profiles/<id>.conf`, or `DEVICE_SCALE_FACTOR=` in the global config.
- **Blur vs lag vs window chrome:** optional `EXTRA_FLAGS` / `EXTRA_ENV` — see [docs/PLATFORM.md](docs/PLATFORM.md) and [examples/profiles/](examples/profiles/).
- **Do not** put `--ozone-platform=x11` on every Chromium app; that is a per-problem opt-in.

## How it works

`add` writes a profile, copies the vendor `.desktop` into `~/.local/share/applications/`, and rewrites `Exec=` to `app-scale-managed <id> <binary> …` (field codes like `%U` stay).

| Path | Role |
|------|------|
| `scripts/app-scale` | CLI: add / list / show / apply / remove |
| `scripts/app-scale-managed` | Wrapper: inject scale, then `exec` the real binary |
| `scripts/app-scale-apply` | Reconciler after vendor refresh |
| `systemd/user/app-scale-apply.*` | Path watch on vendor dirs + daily timer |
| `docs/PLATFORM.md` | X11 / Wayland / Qt platform options |
| `docs/IMPLEMENTATION.md` | Profile schema and flow |

## Limits & safety

This rewrites **user** launchers only (`~/.local/share/applications/`). It does not change Mutter, GDM, or system `.desktop` files in place.

- **Platform:** Chromium/Electron and Qt. GTK and Flatpak are refused with an error.
- **Kill-switch:** `app-scale remove --id ID` or delete the local `.desktop`; the vendor entry returns.
- **Defaults:** no apps wrapped; no ozone/X11 flags; no guessed scale.
- **Tradeoffs:** a terminal command on `PATH` bypasses the wrapper unless you call `app-scale-managed`. Nested `*-managed` wrappers are refused.
- This GitHub repo is the release source for tagged releases and public docs — see [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT — see [LICENSE](LICENSE).

Optional tip jar: [ko-fi.com/alkitect](https://ko-fi.com/alkitect)
