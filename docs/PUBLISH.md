# Publish notes

Before tag: README must pass `./scripts/ci-check.sh` (required H2s + README ban tokens + Ko-fi `FUNDING.yml` / tip link). See [CONTRIBUTING.md](../CONTRIBUTING.md) § README conventions.

First public tag: v0.1.0

Default first tag is 0.1.0. Never copy another alkitect repo’s tag. Use `RC-BEFORE-1.0` in this file only for an intentional 0.9.x RC.

```bash
./scripts/ci-check.sh
git tag -a v0.1.0 -m "v0.1.0"
git push origin main
git push origin v0.1.0
```

Repo URL: `https://github.com/alkitect/linux-app-scale`

## GitHub About

| Field | Value |
|-------|--------|
| Description | Per-app HiDPI scale for Linux launchers that survives snap and deb desktop refreshes |
| Website | _(empty — tip via README Ko-fi badge)_ |
| Topics | `linux`, `ubuntu`, `gnome`, `hidpi`, `fractional-scaling`, `electron`, `qt`, `snap` |

```bash
gh repo edit alkitect/linux-app-scale \
  --description "Per-app HiDPI scale for Linux launchers that survives snap and deb desktop refreshes" \
  --homepage "" \
  --add-topic linux --add-topic ubuntu --add-topic gnome \
  --add-topic hidpi --add-topic fractional-scaling --add-topic electron \
  --add-topic qt --add-topic snap
```

Sidebar (manual if shown): Releases ✓ · Packages ✗ · Deployments ✗
