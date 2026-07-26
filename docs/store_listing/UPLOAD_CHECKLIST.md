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
- ✅ `applicationId` set: `com.trebuchetdynamics.fractal.forge`
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
- ✅ Privacy policy published (`web/privacy-policy.html`, single source)
- 🟡 **JUAN-ACTION-NEEDED:** Publish this policy at a live HTTPS URL and place it in Play Console.

### Hosting status

GitHub Pages is not used and is not enabled for this repository; the public
site is served from Cloudflare Pages and deployed by `scripts/release.sh
website`. Any `*.github.io` URL for this project is stale.

The policy lives at `web/privacy-policy.html`, so the web build copies it into
`build/web` and the website stage publishes it at:

- `https://fractal.trebuchetdynamics.com/privacy-policy`

Use that exact URL in Play Console. Cloudflare Pages serves extensionless
paths, 308-redirecting `/privacy-policy.html` to `/privacy-policy`, so the
canonical address has no `.html`.

> Beware a false pass: the site serves the app shell for unknown paths, so a
> mistyped or unpublished path still returns **HTTP 200** while rendering the
> app. Checking only that a URL "loads" will tick this box incorrectly —
> always check the content.

```bash
# Passes only if the page is really the policy.
# -L matters: without it the .html form's 308 is not followed and this
# reports a false negative on a policy that is correctly published.
curl -sL https://fractal.trebuchetdynamics.com/privacy-policy \
  | grep -qi "privacy policy" && echo OK || echo "NOT the policy"
```

If the URL currently in Play Console is hosted somewhere other than this
repository, record it here so this check can point at the right address.

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