# Google Play First Upload Checklist — Flutter Fractal Forge

Updated: 2026-02-17 02:18 CST (America/Monterrey)

Legend:
- ✅ DONE
- 🟡 JUAN-ACTION-NEEDED

## 1) App build & quality gates
- ✅ Release AAB builds successfully (`build/app/outputs/bundle/release/app-release.aab`)
- ✅ `flutter analyze` clean
- ✅ `flutter test` green (>= 322 pass, 0 fail)
- ✅ Integration test green (`scripts/headless-emulator-test.sh`, 5/5 pass)

## 2) Android app configuration
- ✅ `applicationId` set: `com.fractals.flutter_fractals`
- ✅ `versionCode=1` and `versionName=1.0.0`
- ✅ `targetSdk=34`, `minSdk>=21`
- ✅ Manifest permission minimization complete (`uses-permission` count: 0)

## 3) Store listing assets and text
- ✅ Short description prepared (`store_listing/short_description.txt`)
- ✅ Full description prepared (`store_listing/full_description.txt`)
- ✅ Phone screenshots prepared (`store_listing/screenshots/*_9x16.png`)
- ✅ Feature graphic prepared (`store_listing/feature_graphic.png`, 1024x500)
- ✅ Content rating answers finalized (`store_listing/content_rating_readiness.md`)

## 4) Privacy policy URL requirement
- ✅ Privacy policy content drafted (`store_listing/privacy_policy.md`)
- 🟡 **JUAN-ACTION-NEEDED:** Publish this policy at a live HTTPS URL and place it in Play Console.

### Recommended hosting plan (quickest)
1. Create `docs/privacy-policy.md` (or `docs/privacy-policy/index.html`) in this repo.
2. Enable GitHub Pages for `main` branch `/docs`.
3. Use resulting URL in Play Console, e.g.:
   - `https://xelhaku.github.io/flutter-fractal-forge/privacy-policy/`

(Exact final URL depends on GitHub Pages settings and repo/org naming.)

## 5) App signing / Play App Signing
- ✅ Local upload keystore file exists: `android/app/upload-keystore.jks`
- ✅ Local key properties file exists: `android/key.properties`
- ✅ Release build uses configured `signingConfigs.release`
- 🟡 **JUAN-ACTION-NEEDED:** In Play Console first upload flow, enable/confirm **Play App Signing** and keep backup of upload keystore + credentials offline.
- 🟡 **JUAN-ACTION-NEEDED:** If Google requests key certificate details during setup, provide from local keystore (can be exported with keytool when needed).

## 6) Play Console manual submission steps (cannot be completed from repo)
- 🟡 Create app listing in Play Console (title, short/full description, category)
- 🟡 Upload AAB and complete release notes
- 🟡 Enter privacy policy URL
- 🟡 Complete IARC questionnaire and submit
- 🟡 Complete Data safety form
- 🟡 Configure app access/content declarations
- 🟡 Roll out to internal testing or production

## Final status
Repository-side pre-upload work is complete. Remaining blockers are Play Console and hosting actions owned by Juan.