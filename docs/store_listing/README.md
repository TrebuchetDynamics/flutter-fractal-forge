# Fractal Forge store listing

**Fractal Forge** is the store title in every locale. The current campaign leads with
searchable, checkable promises: what the app renders, what you can export, and what it
never does (ads, accounts, tracking). See the [campaign preview](PREVIEW.md).

## Source of truth

- [Localized copy](../play-store-localized-listings.json): titles, short descriptions and full descriptions for all 15 existing Google Play locales.
- [Asset manifest](assets.json): ordered image groups shared across those locales.
- [Feature graphic](feature_graphic.png): 1024×500 promotional illustration; the matching release asset is `assets/feature-graphic.png`.
- [Phone screenshots](screenshots/phone): seven captioned 1080×1988 images composed from unmodified Android 1.1.120 captures.
- [Tablet screenshots](screenshots/tablet): four captioned 1600×2734 images from the same run, using the responsive tablet layout. Used for both tablet listing groups.
- [Capture manifest](screenshot_captures.json): every composed image's raw capture, caption, dimensions and SHA256 digests.
- [Artwork provenance and prompt](artwork/PROMPTS.md).

Only the caption band is added artwork. Everything below it is the device framebuffer
with the Android status and navigation bars trimmed; the app's own pixels are not
rescaled or retouched.

Short descriptions now lead with the search terms people actually use — fractals,
Mandelbrot, Julia, 3D, 4K wallpaper, GIF, offline — while full descriptions keep a
scannable Explore / Make it yours / Keep and share / Made to be usable structure.

## Screenshot pipeline

```sh
# 1. Capture full-framebuffer Android screenshots (see the recipe below)
# 2. Compose the captioned delivery images and refresh the capture manifest
scripts/compose-store-screenshots.py \
    --raw release-artifacts/store-listing-captures/<run>/ \
    --out docs/store_listing/screenshots/
python3 -m pytest test/scripts/test_compose_store_screenshots.py -q
```

The composer refuses a capture from the wrong device class, a composed aspect ratio
outside Play's 2:1 limit, or a caption that does not fit its band. Raw captures are
kept out of Git (ignored `release-artifacts/`); the manifest keeps their digests so a
delivered image can be traced back to the exact device capture used.

The owner-approved B/open-spiral app-derived Julia icon now supplies the app logo and generated launcher resources. Its [provenance](../../assets/fractal-forge-icon-source.json) retains the untouched app capture and exact transformation. An icon-only Play update was committed and verified across all 15 existing locales, preserving their live text/video and non-icon images. This does not publish an app binary or qualify installed-device appearance; existing installed apps receive the launcher change with a future app update. Screenshots remain English actual captures; localized copy, feature graphic and screenshots are unchanged by this icon-only operation.

## Publish

Requires Python 3 with Pillow, OpenSSL, and a Google Play service account with listing access. Use the existing local `play-console-upload/play-service-account.json`, or set `PLAY_SERVICE_ACCOUNT_JSON`. Never commit credentials.

```sh
scripts/update-play-store-listings.sh --validate-only
# Icon-only changes preserve live text/video and all other image groups:
scripts/update-play-store-listings.sh --icon-only --validate-only
scripts/update-play-store-listings.sh --icon-only --commit
python3 -m unittest test/scripts/test_play_store_listing.py
scripts/update-play-store-listings.sh --audit
scripts/update-play-store-listings.sh --dry-run
scripts/update-play-store-listings.sh --commit
```

Default behavior stages and discards changes. Up to four locales upload concurrently; images within each locale remain ordered. A commit replaces only the image groups named in the manifest, preserves video links, verifies text and ordered image hashes, validates the edit, commits it, and verifies a fresh readback. It does not change binaries, release tracks or app contact details. Local and live locale sets must match exactly.

Backups of listing text and image URLs, staged/readback snapshots, and a digest receipt go under ignored `release-artifacts/store-listing/`. These snapshots do not archive the remote image bytes. A failed staging operation discards the edit. If a commit request has an uncertain network outcome, inspect the live listing using `--audit` before retrying; the script never automatically retries commits or uploads. Play review and public propagation are separate from API commit success.

Optional environment overrides: `PLAY_PACKAGE_NAME`, `PLAY_LOCALIZED_LISTINGS_JSON`, `PLAY_LISTING_ASSETS_JSON`.

## Copy maintenance

Edit the canonical JSON, then mirror it into Fastlane and the English review files:

```sh
scripts/sync-store-copy.py           # write the Fastlane and English copies
scripts/sync-store-copy.py --check   # fail on drift (usable in CI)
```

The regression test also checks Fastlane parity and the IOS-style text limits.
Descriptions use “1,000+” rather than a brittle exact count and qualify
device-dependent rendering and zoom. Do not add AR, MP4 export, unlimited zoom,
guaranteed frame rates, ratings or ranking claims without product evidence.

## Screenshot capture recipe

Use a clean temporary Android user to avoid exposing personal settings, and restore
the previous user and display overrides afterward. The committed images came from an
installed release build on the designated headless Waydroid instance; that is
container rendering evidence, not a physical-device/hardware-GPU qualification.

The capture run is deterministic once the display is set:

```sh
ADB="adb -s $ANDROID_DEVICE"
$ADB shell wm size 1080x1920 && $ADB shell wm density 420   # phone
$ADB shell wm size 1600x2560 && $ADB shell wm density 240  # tablet
$ADB shell am force-stop com.trebuchetdynamics.fractal.forge
$ADB shell am start -a android.intent.action.VIEW \
  -d 'fractalforge://view?type=mandelbrot&x=-0.743643887&y=0.131825904&zoom=2000&iterations=500&colorScheme=6' \
  com.trebuchetdynamics.fractal.forge
$ADB shell screencap -p /sdcard/shot.png && $ADB pull /sdcard/shot.png <raw-dir>/phone/01-mandelbrot.png
```

Deep-link views used for the art slides:

| Slide | View |
|---|---|
| Mandelbrot | `type=mandelbrot&x=-0.743643887&y=0.131825904&zoom=2000&iterations=500&colorScheme=6` |
| Julia | `type=julia&juliaX=-0.8&juliaY=0.156&zoom=1&iterations=500&colorScheme=1` |
| Mandelbulb | `type=mandelbulb&zoom=1&x=0&y=0&rotX=0.2&rotY=0.5&colorScheme=0` |

UI slides are ordinary taps on the running app, located from `adb shell uiautomator
dump` rather than guessed coordinates: long-press the palette tool for the color
sheet, long-press Play to build a two-keyframe camera loop, and open **Save & share →
Export** for the export sheet. The catalog slide filters the catalog to 3D fractals.

The composer trims 76 px of status bar and 96 px of navigation bar from phone captures
(42 px / 84 px on tablet). Re-measure those insets if the device changes, and keep the
caption band free of claims the running build cannot show.

## Reference requirements

[Google Play listing text](https://support.google.com/googleplay/android-developer/answer/9859152) and [preview assets](https://support.google.com/googleplay/android-developer/answer/9866151). The local validator enforces text limits, dimensions, opaque RGB encoding (also fully opaque RGBA for icons), image counts and duplicate prevention before authentication. `--icon-only` validates only the icon and discovers the locale set live; it never PUTs listing text or writes any other image group, and verifies unchanged live metadata before commit and in fresh readback.
