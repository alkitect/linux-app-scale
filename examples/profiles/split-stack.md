# Split stack (two profiles)

When several Chromium apps all use `--ozone-platform=x11`, input lag is a common complaint. Use **two** profiles instead of one global ozone setting.

1. **Scale-critical UI** (browser, mail): copy `chromium-scale-x11.conf.example` — X11 ozone + `SCALE`.
2. **Editor / IDE**: copy `chromium-wayland.conf.example` — native Wayland.

Named illustration (not product SKUs): Brave-class browser on X11 + scale; Cursor-class Electron editor on Wayland.

Steps:

```bash
app-scale add --desktop /path/to/browser.desktop --toolkit chromium --scale 1.25 --id browser
# then edit EXTRA_FLAGS=--ozone-platform=x11 and: app-scale apply --id browser

app-scale add --desktop /path/to/editor.desktop --toolkit chromium --scale 1.25 --id editor
# then edit EXTRA_FLAGS=--ozone-platform=wayland and: app-scale apply --id editor
```

Do not put ozone on the seeded global config. Fully quit each app after apply.
