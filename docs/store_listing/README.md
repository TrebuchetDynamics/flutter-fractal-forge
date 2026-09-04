# Fractal Forge store listing

The September 2026 campaign leads with exploration and creative output: **Fractal Forge**. It replaces technical sales copy, stale catalog counts, and a feature graphic that misspelled the app name and advertised unsupported AR.

[Preview the campaign](PREVIEW.md).

## Source of truth

- [Localized copy](../play-store-localized-listings.json): titles, short descriptions and full descriptions for all 15 existing Google Play locales.
- [Asset manifest](assets.json): ordered image groups shared across those locales.
- [Feature graphic](feature_graphic.png): 1024×500 promotional illustration; the matching release asset is `assets/feature-graphic.png`.
- [Phone screenshots](screenshots/phone): actual Android release 1.1.104 captures at 1080×1920.
- [Tablet screenshots](screenshots/tablet): actual Android release captures at 1600×2560, using its responsive tablet layout. Used for both tablet listing groups.
- [Artwork provenance and prompt](artwork/PROMPTS.md).

The existing launcher icon is retained for brand continuity. Screenshots show the English app UI in every locale; the copy is localized. Screenshots are direct captures, without generated UI or retouching. PNG encoding is normalized to opaque RGB; the generated feature illustration is resized to the required delivery dimensions.

## Publish

Requires Python 3 with Pillow, OpenSSL, and a Google Play service account with listing access. Use the existing local `play-console-upload/play-service-account.json`, or set `PLAY_SERVICE_ACCOUNT_JSON`. Never commit credentials.

```sh
scripts/update-play-store-listings.sh --validate-only
python3 -m unittest test/scripts/test_play_store_listing.py
scripts/update-play-store-listings.sh --audit
scripts/update-play-store-listings.sh --dry-run
scripts/update-play-store-listings.sh --commit
```

Default behavior stages and discards changes. Up to four locales upload concurrently; images within each locale remain ordered. A commit replaces only the image groups named in the manifest, preserves video links, verifies text and ordered image hashes, validates the edit, commits it, and verifies a fresh readback. It does not change binaries, release tracks or app contact details. Local and live locale sets must match exactly.

Backups of listing text and image URLs, staged/readback snapshots, and a digest receipt go under ignored `release-artifacts/store-listing/`. These snapshots do not archive the remote image bytes. A failed staging operation discards the edit. If a commit request has an uncertain network outcome, inspect the live listing using `--audit` before retrying; the script never automatically retries commits or uploads. Play review and public propagation are separate from API commit success.

Optional environment overrides: `PLAY_PACKAGE_NAME`, `PLAY_LOCALIZED_LISTINGS_JSON`, `PLAY_LISTING_ASSETS_JSON`.

## Copy maintenance

Keep the canonical JSON, `fastlane/metadata/android/<locale>/{title,short_description,full_description}.txt`, and the English text files in this directory synchronized. The regression test checks Fastlane parity. Descriptions use “1,000+” rather than a brittle exact count and qualify device-dependent rendering and zoom. Do not add AR, MP4 export, unlimited zoom, guaranteed frame rates, ratings or ranking claims without product evidence.

## Screenshot capture recipe

Use a clean temporary Android user to avoid exposing personal settings. Launch the installed release, capture with `adb shell screencap -p /sdcard/fractal-store-capture.png`, then pull the file. Phone viewport: 1080×1920 at density 420; tablet: 1600×2560 at density 240. Restore the previous user and display overrides afterward.

Exploration view: `/view?type=mandelbrot&zoom=100&x=-0.743643887037151&y=0.13182590420533&colorScheme=0&iterations=1000`. 3D view: `/view?type=mandelbulb&zoom=1&x=0&y=0&rotX=0.2&rotY=0.5&colorScheme=0`. Long-press the palette icon for the color sheet; tap Share & export for export options. Open the catalog from a fresh launcher session.

## Reference requirements

[Google Play listing text](https://support.google.com/googleplay/android-developer/answer/9859152) and [preview assets](https://support.google.com/googleplay/android-developer/answer/9866151). The local validator enforces text limits, image dimensions, RGB PNG encoding, image counts and duplicate prevention before authentication.
