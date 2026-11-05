# All-platform release 1.1.119 — web published, native lanes unconfigured

## Result

The **web** lane qualified and published to the existing Cloudflare Pages
production project. Its automated readback then returned
`publication-unknown`; a separate read-only reconciliation confirmed the
deployment on both production origins. Six lanes did not publish: **Android/Play**
and **F-Droid** were tool-present but the invocation lacked the documented
credential environment (see [Local campaign execution environment](#local-campaign-execution-environment));
**Windows/macOS/iOS** had no native host; **Linux** built and passed its native
journey but remains unknown on the retained-image, EN/ES/inspired-entry and
human-review requirements. No GitHub tag or release, no Play upload, no F-Droid
submission and no Apple/Windows artifact was published. GitHub remains at the
prior release; Play remains at **1.1.105**.

Frozen source: `7abe03c84cb6024529e0eadfad561d3d5d290d90`.
Version **1.1.119**, build number **119**, pinned Flutter **3.47.9**
(`fdroid/flutter.version`), lockfile SHA-256
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

The campaign ran on a clean `main` tree. Earlier retained campaigns
(`release-artifacts/lanes-1.1.119`, `lanes-1.1.119-b`) were prepare-only and
published nothing; they are retained as evidence and were not reused as current
results.

## Web publication

- Deployment `3618fae1-aa34-44b3-9317-185587959c1b`, Production, branch `main`,
  source `7abe03c`, URL `https://3618fae1.flutter-fractal-forge.pages.dev`.
- `https://3618fae1.flutter-fractal-forge.pages.dev` and
  `https://fractal.trebuchetdynamics.com` both serve the qualified
  `release-identity.json` (1.1.119 / 119 / `7abe03c8…`).
- **598/598** manifest files hash-match the qualified bundle on both origins;
  the `_headers` control hash matches and its **573** routes parse and match.
- Tool verdict: `publication-unknown`, "remote readback did not confirm exact
  publication". Cause: the readback ran within seconds of the deploy, before the
  new deployment URL answered; the deployment was live minutes later. This is a
  readback-timing limitation, not a publication failure. Reconciliation record:
  `release-artifacts/lanes-1.1.119-c/web-readback-reconciliation.json`.
- Archive: `fractal-forge-web-v1.1.119.tar.gz`, 22,483,703 bytes, SHA-256
  `b4cb265bec361c7c4c3cafd065aa8d607ef9281fb05733d58553d2016e53bc09`.

## Lane results

| Lane | Build | Qualification | Publication | Exact blocker |
| --- | --- | --- | --- | --- |
| Android/Play | not built | skipped-unavailable | not attempted | `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PROPERTIES_FILE` were absent from the invocation; the keystore and `android/key.properties` exist locally (see recipe) |
| F-Droid | not built | skipped-unavailable | not attempted | `FDROID_BIN` was unset; the container adapter `scripts/ci/fdroid-container.sh` and its cached Podman image are present |
| Web | verified | **verified** | **published** | none |
| Linux | `fractal-forge-linux-x64-v1.1.119.tar.gz`, 21,200,345 bytes, SHA-256 `8ef3efa57dd15fd42c4269a0b07ca4af9186a71c04e99d3a1565fd862c6783b6` | unknown | not attempted | retained edited-view PNG comparisons, EN/ES and inspired-entry coverage, and attributable human review remain open |
| Windows | not built | skipped-unavailable | not attempted | no supported Windows host |
| macOS | not built | skipped-unavailable | not attempted | no Darwin/Xcode host, signing or notarization |
| iOS | not built | skipped-unavailable | not attempted | no Darwin/Xcode host or approved store publisher |

The Android and F-Droid rows are **unconfigured invocations**, not absent
tooling. A run that supplies the documented environment below can build,
qualify and publish those lanes without installing anything or adding a
destination. The Apple lanes are genuinely host-blocked; the Windows lane is
host-blocked as well.

Verified after this release: exporting the recipe below makes the campaign's own
availability check (`release_platform_lanes._host_unavailable`) report
`AVAILABLE` for `android_play`, `fdroid`, `linux` and `web` on this host. Only
`windows`, `macos` and `ios` remain unavailable, and only for their missing
native hosts.

## Local campaign execution environment

This is the recipe that takes the campaign from "credentials unavailable" to a
runnable invocation on this host. Values are names and locations, not secret
contents; never commit or echo them.

| Variable / tool | Value or location | Notes |
| --- | --- | --- |
| `FLUTTER_ROOT` | `/home/xel/flutter` | Must select the provisioned SDK matching `fdroid/flutter.version` (currently 3.47.9); the builder rejects a mismatched or missing SDK |
| `TMPDIR` | an existing task-private scratch directory outside the repository | The builder rejects a missing or in-repository `TMPDIR` |
| `AUTOWORK_PORT_BASE` | a current 100-port allocation in `1024..65436` | Required for native/browser qualification; no default range is authorized |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 ~/.android-upload-keys/flutter-fractal-forge/upload-keystore.jks` | Existing authorized upload keystore |
| `ANDROID_KEY_PROPERTIES_FILE` | `android/key.properties` (gitignored) | `scripts/ci/android-signing.sh` replaces `storeFile` with the decoded keystore |
| `PLAY_SERVICE_ACCOUNT_JSON` | `play-console-upload/play-service-account.json` (gitignored) | Existing Play service account |
| `PLAY_TRACK` / `PLAY_RELEASE_STATUS` | `production` / `completed` | Override only for an explicitly requested nonproduction release |
| `CLOUDFLARE_API_TOKEN` | `./.env` (gitignored) or the CI secret store | Also `CLOUDFLARE_PAGES_PROJECT` (default `flutter-fractal-forge`) |
| `GH_TOKEN` or authenticated `gh` | `gh auth status` already authenticated | GitHub publisher; readback verifies tag and asset hashes |
| Node/wrangler | Node **24** (`~/.nvm/versions/node/v24.19.0`) and `wrangler` on `PATH` | Required for the Pages publisher |
| `FDROID_BIN` | `$PWD/scripts/ci/fdroid-container.sh` | Rootless Podman plus the pinned cached image; no host install |
| `ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE` | `192.168.240.112:5555` | Waydroid, owner-designated; run `waydroid adb connect` first |
| `gh` CLI | `/usr/bin/gh` | Authenticated as the release account |

Waydroid transport: run `waydroid adb connect` (the helper). A raw
`adb connect 192.168.240.112:5555` can fail with *No route to host* while the
helper succeeds. Guest-routing recovery after a real failure needs root for
`sudo systemctl restart waydroid-container`; an unavailable sudo session blocks
that repair, not the target choice.

Exact invocation, from a clean `main` checkout:

```bash
set -a; . ./.env; set +a
export FLUTTER_ROOT=/home/xel/flutter
export TMPDIR="$PWD/.git/autowork-execution/release-scratch"
export AUTOWORK_PORT_BASE=20000            # replace with a current allocation
export ANDROID_KEYSTORE_BASE64="$(base64 -w0 ~/.android-upload-keys/flutter-fractal-forge/upload-keystore.jks)"
export ANDROID_KEY_PROPERTIES_FILE="$PWD/android/key.properties"
export PLAY_SERVICE_ACCOUNT_JSON="$PWD/play-console-upload/play-service-account.json"
export PLAY_TRACK=production PLAY_RELEASE_STATUS=completed
export FDROID_BIN="$PWD/scripts/ci/fdroid-container.sh"
export ANDROID_DEVICE=192.168.240.112:5555
export PATH="$HOME/.nvm/versions/node/v24.19.0/bin:$HOME/.local/bin:$FLUTTER_ROOT/bin:/usr/bin:$PATH"
mkdir -p "$TMPDIR"
waydroid adb connect
adb devices -l

# Prepare and publish in one verified invocation (best-effort policy).
/usr/bin/python3 scripts/release_platform_lanes.py --best-effort --publish 1.1.119 \
  --build-number 119 --artifact-dir release-artifacts/lanes-1.1.119-d \
  --campaign-file release-artifacts/lanes-1.1.119-d/campaign.json
```

Failure signatures seen during this release and their meaning:

| Signature | Meaning |
| --- | --- |
| `FLUTTER_ROOT must select the provisioned pinned SDK` | SDK path unset or mismatched; set the canonical checkout |
| `TMPDIR must be an existing task-private scratch directory` | Scratch path missing or inside the repo; create a private directory |
| `a valid AUTOWORK_PORT_BASE allocation of 100 non-privileged ports is required` | Port base unset/out of range; request an allocation |
| `Android signing credentials unavailable` | The two Android variables above were not exported |
| `F-Droid CLI unavailable …` | `FDROID_BIN` not set to the container adapter |
| `remote readback did not confirm exact publication` (web) | Readback raced the Pages deploy; verify both origins and record a reconciliation before retrying the write |

## Verification

- Shared gate: source integrity and privacy policy passed; `flutter analyze`
  clean; host tests **3,471 passed, 9 skipped**; lockfile unchanged.
- Web: asset validation, browser journey and saved-data checks passed;
  deployed-site readback as above.
- Linux: build, provenance and full native journey command passed; qualification
  stays unknown on the human-review items.

## Limits

Google review status, storefront propagation and end-user availability were not
observed. Waydroid results are container evidence, not physical-device or
hardware-GPU proof. The web archive is published, but no hardware-browser
deployment smoke was run. F-Droid maintainer acceptance and Apple/Windows store
outcomes remain external. This document does not authorize a new destination,
paid capacity or credential change.
