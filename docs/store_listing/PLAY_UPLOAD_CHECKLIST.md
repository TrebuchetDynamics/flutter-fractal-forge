# Play Console Upload Checklist

## Current operational route

For listing-only copy/images, use the [store listing guide](README.md); listing
publication does not release or qualify a binary. For a binary release, follow
the [Play pipeline](../engineering/release/PIPELINE.md):

```sh
scripts/release-play.sh --device "$ANDROID_DEVICE" --disposable-device "$ANDROID_DISPOSABLE_DEVICE"
```

This is the Play-only route, defaulting to **production/completed**. Internal
testing or draft output requires an explicit nonproduction request and override
(`--track internal --release-status draft`); it is not the recommended/default
first step for a production release. An explicit release request authorizes the
qualified subset without another approval, but does not waive any gate.
Bare `./release.sh`, even with `--target play`, selects deferred GitLab; use
`./release.sh --best-effort --prepare=X.Y.Z --build-number=N` and a separate
`./release.sh --best-effort --publish=X.Y.Z --build-number=N` only for an
independent-lane campaign, with the same frozen campaign/artifact paths.

Select the SDK pinned by [`fdroid/flutter.version`](../../fdroid/flutter.version)
(3.47.9 at this revision) and the provisioned cache using the
[common offline setup](../../AGENTS.md#common-offline-integration-gate). Its full
local gate includes Cargo fmt/clippy/locked offline tests, analyzer and
Flutter/Python/Bats with unchanged `pubspec.lock` and `rust/Cargo.lock`.
Local checks and listing validation are not Android production-artifact,
browser, physical-device or cross-platform qualification. Android release tests
use the [designated Waydroid target](../engineering/testing/waydroid-headless.md);
Waydroid remains container evidence, not hardware-GPU proof.

The latest cited [Play receipt is 1.1.125/125](../engineering/release/PLAY_1.1.125.md)
from `6f63c28b`, production/completed. At 2026-11-20T05:05:45Z propagation was still
pending; do not reupload to address it. Review and end-user availability were
unconfirmed, and no other lane was requalified. This is a dated receipt, not a
fresh live status check. For website/policy deployment use the separate
[web procedure](../deployment/WEB_PREVIEW_GITHUB_PAGES.md), not a Play upload.

## Historical checklist — 2026-06-05

The snapshot below retains its original artifact sizes, test counts, identity,
manual steps and observations. DONE/pending boxes and first-upload instructions
are dated history, not current readiness or an instruction to create the app,
reupload an AAB, choose internal testing, or deploy the website again. The current
route above supersedes those operational recommendations.

Updated: 2026-06-05 CST (America/Monterrey)

This checklist is for Google Play Console maintenance releases. The app is published on Google Play; keep all signing material private and outside the public repository.

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
- [DONE] Phone screenshots (seven captioned images, 1080×1988)
  - `docs/store_listing/screenshots/phone/01-mandelbrot.png`
  - `docs/store_listing/screenshots/phone/02-julia.png`
  - `docs/store_listing/screenshots/phone/03-mandelbulb.png`
  - `docs/store_listing/screenshots/phone/04-catalog.png`
  - `docs/store_listing/screenshots/phone/05-palette.png`
  - `docs/store_listing/screenshots/phone/06-export.png`
  - `docs/store_listing/screenshots/phone/07-looper.png`
- [DONE] Tablet screenshots (four captioned images, 1600×2734)
  - `docs/store_listing/screenshots/tablet/*.png`

### Policy and questionnaire docs
- [DONE] Content rating answers
  - Path: `store_listing/content_rating_readiness.md`
- [DONE] Privacy policy text draft
  - Path: `web/privacy-policy.html`
- [DONE] Permissions audit
  - Path: `store_listing/manifest_permissions_audit.md`

## B) Privacy policy URL requirement

Google Play requires a **public HTTPS URL** for the privacy policy.

- Public app/site: `https://fractal.trebuchetdynamics.com`
- Source of truth: `web/privacy-policy.html` (deployed with the site)
- Published policy: `web/privacy-policy.html` -> `/privacy-policy` (live)

Confirm the deployed privacy policy URL actually serves the policy before
pasting it into Play Console — not merely that it loads. The site returns the
app shell with HTTP 200 for unknown paths, so a status-code check passes even
when the policy is not published:

```bash
# -L is required: Cloudflare Pages 308-redirects the .html form to the
# extensionless path, so omitting it reports a false negative.
curl -sL "$URL" | grep -qi "privacy policy" && echo OK || echo "NOT the policy"
```

See `UPLOAD_CHECKLIST.md` for current hosting status.

## C) App signing readiness

- [REQUIRED] Keep the upload keystore and passwords private; do not commit them.
- [REQUIRED] Create local-only `android/key.properties` from `android/key.properties.example`.
- [REQUIRED] Store the private upload keystore outside the repository when possible.
- [DONE] Release build is configured to use signing config from local `android/key.properties`.
- [DONE] `scripts/build-play-console.sh` verifies the upload certificate SHA1 before producing a Play artifact.

### Owner-required Play Console steps
- [OWNER-ACTION-NEEDED] Confirm Play App Signing / upload-key fingerprint before each release.
- [OWNER-ACTION-NEEDED] Keep offline backups of the upload keystore and credentials.

## D) Historical Play Console submission steps (superseded)

1. [JUAN-ACTION-NEEDED] Create app entry in Play Console.
2. [JUAN-ACTION-NEEDED] Upload AAB from:
   - `build/app/outputs/bundle/release/app-release.aab`
3. [JUAN-ACTION-NEEDED] Fill Store Listing:
   - Short description from `store_listing/short_description.txt`
   - Full description from `store_listing/full_description.txt`
4. [JUAN-ACTION-NEEDED] Upload graphics:
   - Feature graphic `store_listing/feature_graphic.png`
   - Screenshots from `docs/store_listing/screenshots/phone/*.png`
5. [JUAN-ACTION-NEEDED] Complete Content Rating using `store_listing/content_rating_readiness.md`.
6. [JUAN-ACTION-NEEDED] Enter Privacy Policy URL (published from `web/privacy-policy.html`).
7. [JUAN-ACTION-NEEDED] Complete Data Safety and other policy declarations.
8. [JUAN-ACTION-NEEDED] Submit to Internal Testing (recommended first), then production rollout.

## E) Validation snapshot at time of checklist

- `flutter analyze`: clean
- `flutter test`: 322 passed, 3 skipped, 0 failed
- Integration (`scripts/headless-emulator-test.sh`): flaky due emulator/ADB offline in this run; prior runs were green (5/5)
- `flutter build appbundle --release`: success
