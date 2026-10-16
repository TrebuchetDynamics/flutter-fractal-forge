# Google Play listing assets

The current delivery files and their order are defined in [assets.json](assets.json). See [README.md](README.md) for publishing and capture provenance.

| Asset | Campaign dimensions | Encoding |
|---|---|---|
| Feature graphic | 1024×500 | Opaque RGB PNG |
| App icon | 512×512, at most 1024 KB | Opaque sRGB 32-bit RGBA PNG |
| Phone screenshots | 1080×1920 | RGB PNG |
| Tablet screenshots | 1600×2560 | RGB PNG |

Google Play screenshots must be between 320 and 3840 pixels on each side, with the long side no more than twice the short side. Use actual app captures and up to eight images per device group. This campaign supplies at least four per group.

Title: at most 30 characters. Short description: at most 80. Full description: at most 4000. All fields must be nonempty.

Source: [Google Play preview assets](https://support.google.com/googleplay/android-developer/answer/9866151).


## App-derived icon replacement

The owner-approved B/open-spiral icon comes from the production app Julia renderer, with exact saved parameters, untouched source and recorded 45-degree clockwise rotation/crop. [Provenance](../../assets/fractal-forge-icon-source.json) owns source/output hashes; the raw capture, state, preset and mask proof are retained under `assets/icon/zig_zag_julia/`.

`assets/icon/ic_launcher_512.png` is a full-square opaque sRGB 32-bit RGBA PNG, 512×512 and below 1024 KB, without baked outer shadow or rounded mask. Screenshots and feature graphics remain RGB. The validator now allows fully opaque RGBA for icons only, with transparency/dimension/size regressions. Android adaptive foreground/background remain separate launcher assets.

The icon-only Play edit was committed and verified from a fresh edit across all 15 current locales. Uploaded SHA256: `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41`. Live text/video and all inspected non-icon image groups are unchanged. Public review/propagation and actual installed-device appearance are not claimed; no app binary or release track changed. See [the accepted scope and actual authority](../engineering/spec.md#app-derived-zig-zag-julia-icon).
