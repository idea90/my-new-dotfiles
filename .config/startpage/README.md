# Kaleido start page

A new-tab page for Firefox or Chrome that follows your matugen colors and wallpaper.

`server.py` (started by Hyprland, listens on 127.0.0.1:7391 only) hands the extension the
current `colors.json` and wallpaper. The extension polls every 5 seconds, so changing the
wallpaper recolors open new tabs.

## Install

- **Firefox:** `about:debugging` → This Firefox → Load Temporary Add-on → pick `extension/manifest.json`.
  For a permanent install, zip the `extension/` folder and sign it at addons.mozilla.org (unlisted),
  or use Firefox Developer Edition / Nightly with `xpinstall.signatures.required = false`.
- **Chrome / Chromium:** `chrome://extensions` → Developer mode → Load unpacked → pick `extension/`.

If the page shows "Start page server not running", run `python3 ~/.config/startpage/server.py`.
