# Contributing

## README conventions

Public README required H2s (exact strings; enforced by `./scripts/ci-check.sh`):

```text
## What this does
## Who this is for
## Quick start
## Check it works
## Uninstall
## Limits & safety
## License
```

Put the beginner path (install / verify / uninstall) above limits. Do not put private monorepo paths or the token `SSOT` in README prose — say “release source” instead.

Also enforced by `./scripts/ci-check.sh`:

- `.github/FUNDING.yml` with `ko_fi: alkitect`
- README Ko-fi GitHub button (`githubbutton_sm.svg` → `ko-fi.com/alkitect`) under the tagline
- README soft tip containing `ko-fi.com/alkitect` (after License)
- README must not link Patreon or Buy Me a Coffee
- Seeded `config/example.config` must not assign `DEVICE_SCALE_FACTOR` or `--ozone-platform`

Gate: `./scripts/ci-check.sh`.

## Versioning

First public tag is recorded in `docs/PUBLISH.md` (`First public tag:`). Default is **0.1.0**. Never copy another alkitect repo’s tag. Use `RC-BEFORE-1.0` in PUBLISH only for an intentional 0.9.x RC. After the first tag, bump from CHANGELOG Unreleased (`feat` → minor, `fix` → patch). Maintainers: `./scripts/ci-check.sh` must pass before tag.

## Bug reports

Please include:

- Distro and desktop (expect GNOME Wayland)
- Toolkit (`chromium` / `qt`), `--scale`, and whether `EXTRA_FLAGS` / `EXTRA_ENV` are set
- The `.desktop` path you passed to `app-scale add` (not host-private notes)
- `app-scale show --id ID` (redact home directory if you prefer)

## Behavior changes

If you change wrapper or reconciler semantics, update:

- [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md)
- [docs/PLATFORM.md](docs/PLATFORM.md) when platform extras change

Run before PR:

```bash
./scripts/ci-check.sh
```

## Sync policy (dual maintenance)

- **Release source:** this GitHub repository (tagged releases, public docs).
- A private Linux customization tree may keep per-app wrappers until they are migrated onto profiles.
- **Never** sync private Cursor plans, machine journals, or host-specific ozone defaults into this repo.
- **Conflicts:** a human maintainer chooses; no automatic overwrite.

## Safety defaults

Shipped `example.config` does not wrap apps and does not set ozone or a guessed scale. Do not add `--ozone-platform` to the seeded global config without a version bump and README warning.
