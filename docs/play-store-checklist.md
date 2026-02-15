# Google Play Store Release Checklist — Flutter Fractal Forge

This checklist is for preparing a **stable Play Store release**.

## 1) App signing key (REQUIRED)
- [ ] Decide signing strategy:
  - [ ] **Play App Signing** (recommended): upload key + Google manages app signing key
  - [ ] Self-managed signing (advanced)
- [ ] Generate upload keystore (store securely, back up offline)
- [ ] Configure `android/key.properties` (DO NOT COMMIT) + `android/app/build.gradle` signingConfigs
- [ ] Verify release build is signed:
  - [ ] `./gradlew :app:signingReport`
  - [ ] Install release APK / AAB on device
- [ ] Document key alias + location in your private vault (not in repo)

## 2) Build artifact type
- [ ] Prefer **AAB** for Play Store:
  - [ ] `flutter build appbundle --release`
- [ ] Verify size + startup on a real device

## 3) Store listing metadata
- [ ] App name (title)
- [ ] Short description (80 chars)
- [ ] Full description
- [ ] App icon (512×512)
- [ ] Feature graphic (1024×500)
- [ ] Promo video (optional)

### Screenshots (minimum + dimensions)
Typical requirements (verify in Play Console as they can change):
- [ ] Phone screenshots: at least 2
  - Common: 16:9 or 9:16, minimum ~320px, maximum ~3840px per side
- [ ] 7-inch tablet screenshots (optional but recommended)
- [ ] 10-inch tablet screenshots (optional)

For this app specifically, capture:
- [ ] Catalog screen
- [ ] Viewer screen (CPU mode) with controls open
- [ ] Settings: Renderer backend mode (Auto/CPU/GPU)
- [ ] Export/share flow

## 4) Privacy policy URL (REQUIRED)
- [ ] Create a privacy policy page (public URL)
- [ ] State what data is collected (if any):
  - [ ] Crash logs / diagnostics
  - [ ] Analytics (if any)
  - [ ] User-generated content (saved presets, imported formulas)
- [ ] If no network collection: explicitly say **no data leaves device**

## 5) Data safety form (Play Console)
- [ ] Fill Data Safety section
- [ ] Declare camera permission usage (AR overlay) if present
- [ ] Declare storage/file access (import/export)
- [ ] Declare any sharing endpoints

## 6) Content rating questionnaire
- [ ] Complete IARC content rating
- [ ] Note: fractal visuals can include flashing patterns → consider an epilepsy warning in-app + listing

## 7) Target API level compliance (REQUIRED)
- [ ] Confirm targetSdkVersion meets current Play requirements
- [ ] Confirm compileSdkVersion meets current Play requirements
- [ ] Update dependencies for Android 13/14+ permission behavior as needed
- [ ] Verify scoped storage compliance

## 8) Policy / QA gates
- [ ] No GPL bundling (Option B):
  - [ ] Do not ship GPL code or third-party formula packs
  - [ ] User import for `.frm/.ufm` is OK
- [ ] Run:
  - [ ] `flutter analyze`
  - [ ] `flutter test`
- [ ] Real device smoke test (recommended):
  - [ ] CPU mode renders correctly
  - [ ] GPU mode works or cleanly falls back
  - [ ] Performance acceptable

## 9) Release process
- [ ] Create versionCode/versionName bump
- [ ] Generate release notes
- [ ] Upload AAB to internal testing track
- [ ] Verify install from Play
- [ ] Rollout staged release
