# linux-app-scale

Per-app HiDPI scale for Linux launchers that survives snap and deb desktop refreshes.

[Quick start](#quick-start) · [PLATFORM](docs/PLATFORM.md) · [Releases](https://github.com/alkitect/linux-app-scale/releases) · [License](#license)

Latest release notes: [CHANGELOG.md](CHANGELOG.md) and [GitHub Releases](https://github.com/alkitect/linux-app-scale/releases). A plain `git clone` follows the default branch tip unless you check out a tag; prefer a tagged release for day-to-day use.

## What this does

GNOME fractional scaling often leaves Electron and Qt apps blurry. Forcing the whole session to 100% makes those apps sharp but tiny; per-app scale flags fix one app without changing Mutter.

This tool wraps a `.desktop` `Exec=` line so the dock and app grid launch `app-scale-managed`, which injects Chromium `--force-device-scale-factor` or Qt `QT_SCALE_FACTOR`. A reconciler copies the vendor launcher back after a snap or package refresh.

Safe by default: install wraps no apps and adds no X11/ozone flags. You choose a toolkit, a scale, and (optionally) platform extras per profile.

## Who this is for

This is for Ubuntu / GNOME (other XDG desktops usually work) with HiDPI or fractional scale, and Snap or `.deb` apps whose `.desktop` file you can point at (`--desktop PATH`).

It is not for GDM/login scaling, Flatpak (`flatpak run`), GTK-only apps, or changing GNOME's session scale.

## Quick start

Install puts `app-scale`, `app-scale-managed`, and `app-scale-apply` in `~/.local/bin`, plus a seeded `~/.config/linux-app-scale/config` that does not wrap anything. You still add one app, fully quit it, and launch from Activities. Optional path + timer: `./scripts/install-to-local.sh --enable-automation`.

Then: [Install](#install) → [Try one app](#try-one-app).

### Install

Needs: `bash`, `python3`, write access to `~/.local`, and a session that honors `~/.local/share/applications/` (GNOME does).

Stable path: clone or download a release tag from [Releases](https://github.com/alkitect/linux-app-scale/releases), then run the install script. Tip of the default branch is fine for contributors.

```bash
git clone https://github.com/alkitect/linux-app-scale.git
cd linux-app-scale
# optional: git checkout vX.Y.Z   # pin to a release tag
./scripts/install-to-local.sh
```

Stay safe before enabling automation: add one app first, then enable the path unit. Platform flags (X11 ozone, Qt xcb) stay off unless you copy them from [docs/PLATFORM.md](docs/PLATFORM.md).

### Try one app

Replace the `.desktop` path and toolkit with your app (`chromium` for Electron/Chrome-family, `qt` for Qt). Common scales: `1.25`, `1.5`, `2.0`.

```bash
app-scale add --desktop /var/lib/snapd/desktop/applications/signal-desktop_signal-desktop.desktop \
  --toolkit chromium --scale 1.25
# Fully quit the app, then launch it from Activities (not a terminal).
```

Success: the UI looks sharp at the scale you chose after a full quit and an Activities/dock launch. A terminal command on `PATH` bypasses the wrapper unless you call `app-scale-managed`.

## Check it works

You want `apply --check` clean and the local `.desktop` `Exec=` pointing at `app-scale-managed`. If the app still looks blurry, quit it fully and launch from the dock, not a terminal alias. If scale is wrong: `app-scale show --id ID`, edit `SCALE=`, then `app-scale apply --id ID`.

<details>
<summary>Optional confirmation scripts</summary>

```bash
APP_SCALE_ROOT="$PWD" ./scripts/verify-linux-app-scale.sh
app-scale list
app-scale apply --dry-run
./scripts/ci-check.sh
```

</details>

Questions or a stuck install: open a GitHub [Issue](https://github.com/alkitect/linux-app-scale/issues) or see [CONTRIBUTING.md](CONTRIBUTING.md).

## Support my work

Tip jar for the next desktop fix. Or a coffee so the next script stays boring on purpose.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/alkitect/?hidefeed=true&widget=true&embed=true)

## Uninstall

```bash
app-scale remove --id ID --purge-config   # one app; GNOME falls back to the vendor launcher
./scripts/uninstall-from-local.sh
# also remove remaining profiles:
./scripts/uninstall-from-local.sh --purge-config
```

## Configure

- Scale: `--scale` on add, or `SCALE=` in `~/.config/linux-app-scale/profiles/<id>.conf`, or `DEVICE_SCALE_FACTOR=` in the global config.
- Blur vs lag vs window chrome: try scale-only first ([examples/README.md](examples/README.md)); extras in [docs/PLATFORM.md](docs/PLATFORM.md).
- Do not put `--ozone-platform=x11` on every Chromium app; that is a per-problem opt-in.
- Do not wrap the same `.desktop` with this tool and a per-app `*-managed` installer (Brave/Signal/Telegram/Proton topics). `add` refuses nested wrappers.

## How it works

`add` writes a profile, copies the vendor `.desktop` into `~/.local/share/applications/`, and rewrites `Exec=` to `app-scale-managed <id> <binary> …` (field codes like `%U` stay). After a vendor refresh, `app-scale-apply` (and optional systemd path/timer) puts the wrapper back.

More detail: [docs/PLATFORM.md](docs/PLATFORM.md) · [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md).

## Limits & safety

This rewrites user launchers only (`~/.local/share/applications/`). It does not change Mutter, GDM, or system `.desktop` files in place.

- Platform: Chromium/Electron and Qt via snap or `.deb` `.desktop` files. GTK and Flatpak are refused with an error.
- Kill-switch: `app-scale remove --id ID` or delete the local `.desktop`; the vendor entry returns.
- Defaults: no apps wrapped; no ozone/X11 flags; no guessed scale.
- Tradeoffs: a terminal command on `PATH` bypasses the wrapper unless you call `app-scale-managed`. Nested `*-managed` wrappers are refused. This release does not replace host-specific Brave PWA / Telegram / Signal / Proton installers.
- This GitHub repo is the release source for tagged releases. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

Optional tip jar: [ko-fi.com/alkitect](https://ko-fi.com/alkitect/?hidefeed=true&widget=true&embed=true)
