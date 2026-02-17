# Play Console Upload Checklist (First Submission)

Updated: 2026-02-17 03:18 CST (America/Monterrey)

This checklist is intended for Juan to execute directly in Google Play Console.

## A) Artifacts verified on disk

### App bundle
- [DONE] Release AAB
  - Path: `build/app/outputs/bundle/release/app-release.aab`
  - Latest verified size: ~47.7MB

### Store listing text
- [DONE] Short description
  - Path: `store_listing/short_description.txt`
- [DONE] Full description
  - Path: `store_listing/full_description.txt`

### Graphics
- [DONE] Feature graphic (exact 1024x500)
  - Path: `store_listing/feature_graphic.png`
- [DONE] Phone screenshots (portrait 9:16)
  - `store_listing/screenshots/01_catalog_9x16.png`
  - `store_listing/screenshots/02_mandelbrot_9x16.png`
  - `store_listing/screenshots/03_second_module_9x16.png`

### Policy and questionnaire docs
- [DONE] Content rating answers
  - Path: `store_listing/content_rating_readiness.md`
- [DONE] Privacy policy text draft
  - Path: `store_listing/privacy_policy.md`
- [DONE] Permissions audit
  - Path: `store_listing/manifest_permissions_audit.md`

## B) Privacy policy URL requirement (hostable plan)

Google Play requires a **public HTTPS URL** for the privacy policy.

- Current text is ready to publish: `store_listing/privacy_policy.md`
- No fixed custom domain is required; GitHub Pages is sufficient.

### Recommended publish flow (Juan action)
1. Copy privacy policy content into a published page in this repo (`docs/privacy-policy.md` or `docs/privacy-policy/index.html`).
2. Enable GitHub Pages for the repository.
3. Confirm public URL loads in browser.
4. Paste URL into Play Console Privacy Policy field.

Expected URL pattern (if using GitHub Pages):
- `https://xelhaku.github.io/flutter-fractal-forge/...`

## C) App signing readiness

- [DONE] Upload keystore file exists: `android/app/upload-keystore.jks`
- [DONE] Key properties file exists: `android/key.properties`
- [DONE] Release build is configured to use signing config from key.properties.

### Juan-required Play Console steps
- [JUAN-ACTION-NEEDED] Enable/confirm Play App Signing during first upload flow.
- [JUAN-ACTION-NEEDED] Keep offline backup of upload keystore and credentials.

## D) Play Console submission steps (manual)

1. [JUAN-ACTION-NEEDED] Create app entry in Play Console.
2. [JUAN-ACTION-NEEDED] Upload AAB from:
   - `build/app/outputs/bundle/release/app-release.aab`
3. [JUAN-ACTION-NEEDED] Fill Store Listing:
   - Short description from `store_listing/short_description.txt`
   - Full description from `store_listing/full_description.txt`
4. [JUAN-ACTION-NEEDED] Upload graphics:
   - Feature graphic `store_listing/feature_graphic.png`
   - Screenshots from `store_listing/screenshots/*_9x16.png`
5. [JUAN-ACTION-NEEDED] Complete Content Rating using `store_listing/content_rating_readiness.md`.
6. [JUAN-ACTION-NEEDED] Enter Privacy Policy URL (published from `store_listing/privacy_policy.md`).
7. [JUAN-ACTION-NEEDED] Complete Data Safety and other policy declarations.
8. [JUAN-ACTION-NEEDED] Submit to Internal Testing (recommended first), then production rollout.

## E) Validation snapshot at time of checklist

- `flutter analyze`: clean
- `flutter test`: 322 passed, 3 skipped, 0 failed
- Integration (`scripts/headless-emulator-test.sh`): flaky due emulator/ADB offline in this run; prior runs were green (5/5)
- `flutter build appbundle --release`: success
