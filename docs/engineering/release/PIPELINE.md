# Release pipeline

Status: current. This is the canonical description of how a release is prepared,
qualified, published and recorded in this repository. Platform policy lives in
[MULTIPLATFORM.md](MULTIPLATFORM.md); product-level constraints live in the
[PRD standing release defaults](../../../PRD.md#standing-release-defaults).
Where those documents and this one disagree about a command name, this one wins
because it describes the scripts as they exist.

GitLab is excluded by the owner's deferral. Nothing here dispatches GitLab CI,
mirrors repositories, or authorizes a new destination.

## Entry points

| Goal | Command |
| --- | --- |
| Release the current `main` to Play production | `scripts/release-play.sh --device <id> --disposable-device <id>` |
| See what Play serves right now | `scripts/ci/play-status.sh --pretty` |
| Run only the shared offline gate | `scripts/ci/offline-gate.sh --json` |
| Run only the Android device gate | `scripts/pre-release-gate.sh --device <id> --disposable-device <id>` |
| Prepare every independent lane | `/usr/bin/python3 scripts/release_platform_lanes.py --best-effort --prepare X.Y.Z --build-number N --artifact-dir … --campaign-file …` |
| Publish those prepared lanes | the same command with `--publish X.Y.Z` |

`scripts/release-play.sh` is the Play-only path. It is *fail-closed*: no gate, no
upload; a failed readback never triggers a second upload. The lane campaign is
the multi-platform path and keeps its own per-lane evidence contract.

## Play pipeline stages

`scripts/release-play.sh` runs these stages in this order. Each row states what
the stage actually proves and what it does not.

| Stage | Command it runs | Proves | Does not prove |
| --- | --- | --- | --- |
| 1. Identity preflight | git/`fdroid/version.properties`/`pubspec.yaml` checks | the requested version matches the committed identity, the tree is clean, and an existing tag does not point elsewhere | that the version code is free on Play |
| 2. Play preflight | `scripts/ci/play-status.sh` (or `--play-status-json`) | the version code is unused and newer than the latest consumed code | that Google accepted anything |
| 3. Shared offline gate | `scripts/ci/offline-gate.sh` | pinned SDK, unchanged lockfile, analyzer, Flutter host tests, Python tests, Bats tests | device, browser, GPU, store or review behaviour |
| 4. Device gate | `scripts/pre-release-gate.sh --skip-host` | install/journey/rendering/accessibility/performance/restoration/offline/soak on the designated target | physical-device or hardware-GPU qualification |
| 5. Build + upload | `scripts/build-upload-playstore.sh` | a signed AAB with the expected version code/hash was uploaded to the requested track and the edit committed | review outcome or storefront propagation |
| 6. Readback + evidence | `scripts/ci/play-readback.sh`, then evidence files | a fresh edit reports the exact version code, hash, track and status | end-user availability |

Stage 3 and 4 can be skipped only by explicit flag, and a skip is written into
the evidence file as `skipped`. Skipping is a recorded gap, never an implicit
pass.

## Identity rules

- `fdroid/version.properties` is the committed release identity (`versionName`,
  `versionCode`). Commit it before releasing; the pipeline refuses a mismatch.
- `versionName` is `<pubspec major>.<minor>.<build number>` and the build number
  equals the Play `versionCode`. `pubspec.yaml` keeps its own `+N`, which the
  Play builder overrides.
- Version codes are one-way. The pipeline refuses a code that already appears in
  the Play bundle history or on the track, and refuses one that is not newer than
  the latest consumed code. Gaps are allowed and are printed (`gap N`).
- If `v<version>` already exists, it must point at `HEAD`; the pipeline will not
  move a published tag.
- A consumed untagged version can be confirmed explicitly with the release
  version policy checks used by `test/scripts/release_version_resolver.bats`.

## Prerequisites

Locations only; never commit or echo secret contents.

| Variable / tool | Value or location | Needed by |
| --- | --- | --- |
| `FLUTTER_ROOT` | `/home/xel/flutter` (must match `fdroid/flutter.version`) | offline gate, builders |
| `TMPDIR` | existing private scratch directory outside the checkout | offline gate, campaign builder |
| `PLAY_SERVICE_ACCOUNT_JSON` | `play-console-upload/play-service-account.json` (gitignored) | status, upload, readback |
| `PLAY_TRACK` / `PLAY_RELEASE_STATUS` | `production` / `completed` | upload defaults; override only for an explicitly requested nonproduction release |
| `ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE` | current serial, e.g. `192.168.240.112:5555` | device gate (both must match) |
| `android/key.properties` + upload keystore | `storeFile` is resolved by the builder | AAB signing |
| `AUTOWORK_PORT_BASE` | current 100-port allocation in `1024..65436` | native/browser lanes of the campaign (not Play) |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_PROPERTIES_FILE` | keystore and properties pair | campaign Android lane |
| `FDROID_BIN` | `$PWD/scripts/ci/fdroid-container.sh` | F-Droid lane |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_PAGES_PROJECT` | `./.env` or CI secret store | web lane |
| `GH_TOKEN` or authenticated `gh` | `gh auth status` | GitHub release lane |
| Node 24 + `wrangler`, `java`, `curl`, `openssl`, `/usr/bin/python3` | host tools | publishers, gates |

A missing prerequisite is reported as a refusal (Play pipeline) or a lane skip
(campaign). A lane marked `skipped-unavailable` means the invocation did not
supply the prerequisite, not that the repository lacks a tool.

```bash
export FLUTTER_ROOT=/home/xel/flutter
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
export TMPDIR=/path/outside/checkout
export PLAY_SERVICE_ACCOUNT_JSON="$PWD/play-console-upload/play-service-account.json"
export ANDROID_DEVICE=192.168.240.112:5555
export ANDROID_DISPOSABLE_DEVICE="$ANDROID_DEVICE"
waydroid adb connect
adb devices -l
```

Full multi-lane environment (ports, keystore pair, F-Droid adapter, Cloudflare,
Node/wrangler) is in the campaign section of [MULTIPLATFORM.md](MULTIPLATFORM.md#local-campaign-execution-environment).

## Failure handling

| Signature | Meaning | Action |
| --- | --- | --- |
| `version code N is already consumed on Play` | that code was uploaded before | bump `fdroid/version.properties`, commit, rerun |
| `build number N is not newer than the latest consumed version code M` | descending identity | choose a code above `M` |
| `requested … does not match fdroid/version.properties` | identity not prepared/committed | commit the release preparation first |
| `working tree is dirty` | uncommitted changes | commit, or pass `--allow-dirty` and accept a recorded warning |
| `Flutter X does not match pinned Y` | wrong SDK on `PATH` | select the SDK named by `fdroid/flutter.version` |
| `pubspec.lock changed during …` | dependency metadata drift | restore the lockfile; do not publish |
| `shared offline gate failed; nothing was published` | host gate red | read `gates/offline-gate.json`, fix, rerun |
| `device gate failed; nothing was published` | device gate red | read `gates/device-gate.log`; do not retry the upload |
| `DO NOT upload again` | upload committed but readback unconfirmed | run `scripts/ci/play-status.sh --pretty`, reconcile version/hash, then decide |
| `did not complete` in the combined device suite | the runner lost a test, no crash/ANR in logcat | rerun the same invocation once; keep both results and record the flake |
| `Android signing credentials unavailable` | campaign Android env incomplete | export the keystore pair |
| `F-Droid CLI unavailable` | `FDROID_BIN` unset | point it at the cached container adapter |
| `required native host unavailable: darwin\|windows` | no such host exists here | record skipped-unavailable; do not substitute |

Waydroid transport: use `waydroid adb connect`; a raw `adb connect` can fail with
*No route to host* while the helper succeeds. See the
[Waydroid contract](../testing/waydroid-headless.md#working-android-test-sequence).

## Evidence

The pipeline writes everything under `release-artifacts/play-<version>/`
(gitignored):

```
release-play-evidence.json     machine summary: identity, gates, artifact, Play readback
PLAY_RECORD_STUB.md            the observed facts for the committed record
play-publication-receipt.json  Play edit id, track, status, AAB hash
play-readback.json             independent readback verdict
fractal-forge-…-build<N>-…aab  the published artifact (+ .sha256)
gates/offline/                 per-stage logs + offline-gate.json
gates/device/                  device gate log and screenshots
```

Only the publication record is committed, at
`docs/engineering/release/PLAY_<version>.md`. Artifacts and receipts stay
ignored; they are evidence for a human, not repository content.

## Publication record contract

A record must state the observed facts, not the intention:

- package, version/build, track and release status, Play edit id, receipt
  timestamp, release source commit, AAB bytes and SHA-256, upload certificate
  SHA-1, and the independent readback output;
- the changelog delta relative to the *previously published* build, not the
  last prepared one;
- qualification numbers per gate (analyzer, test counts, device suite counts,
  soak PSS/jank/thermal, crash evidence) with skipped/unknown items named;
- any flake or aborted attempt that preceded the passing run;
- limits: review status, storefront propagation, end-user availability, and
  which other lanes were untouched.

`PLAY_RECORD_STUB.md` gives the facts; the prose, changelog and limits are still
written by hand.

## Multi-lane campaign

`scripts/release_platform_lanes.py` owns per-lane preparation, qualification,
publication and readback for `android_play`, `fdroid`, `web`, `linux`,
`windows`, `macos` and `ios`. It reads the same environment documented above and
keeps the shared barrier (privacy policy, source identity, analyzer, host tests,
lockfile) before any lane proceeds.

Play is the one lane with a dedicated single-command wrapper because it is the
only lane whose destination is configured locally end to end. The wrapper does
not replace the campaign; a campaign run still validates and publishes its own
Play lane, and mixing the two on the same version code will be refused by the
consumed-code check.

## Release ritual

1. Decide the version code from `scripts/ci/play-status.sh`, not from memory.
2. Commit `fdroid/version.properties` + `fastlane/metadata/android/en-US/changelogs/<build>.txt`.
3. `scripts/release-play.sh --dry-run --play-status-json <status.json>` to see the
   plan and the version-code verdict without touching anything.
4. Run the real pipeline; keep the artifact directory.
5. Copy `PLAY_RECORD_STUB.md` into a `PLAY_<version>.md` record, fill in the
   prose, and commit it together with any release-identity change.
6. Update the "Current release status" pointer in [MULTIPLATFORM.md](MULTIPLATFORM.md).
7. Push. Then run `scripts/ci/play-observe.sh` and attach its JSON to the
   record. Review outcome and per-device availability remain separate
   observations; the script records review as not observable.

## Observing review, storefront propagation and availability

`scripts/ci/play-observe.sh` reports what Play serves after a publication. It is
read-only and does not replace any gate.

```bash
scripts/ci/play-observe.sh \
  --expected-version 1.1.121 \
  --expected-date "Nov 6, 2026" \
  --output release-artifacts/play-1.1.121/play-observe.json
```

The command combines two sources.

| Source | Observed | Not observed |
| --- | --- | --- |
| Play Developer API | track release name, rollout status, version codes, user fraction; targeted countries and `restOfWorld`; default language | Google app-review status |
| Public storefront per country | HTTP status, listing availability, `Updated on` date, embedded version when the page exposes it | installation on a specific device or account |

The storefront summary splits countries into `propagated` (listed date and
version match the expectation), `pending` (listed but older), `unavailable`
(HTTP 404) and `errors` (other status). A 200 page with the release date is
propagation evidence. It is not proof that an account or device can install the
build.

**Google review has no public API endpoint.** The script records
`review.status = not-observable` and lists the practical signals:

- Play Console > Publishing overview shows changes in review.
- The developer account receives the Google review email.
- The storefront lists the new date and version after approval and propagation.
- A track status of `completed` is rollout state, not review approval.

Do not convert any of these signals into an approval claim. Record the review as
not observed until the Console or the email confirms it.

Limits: the storefront page is not an official API. Geo/IP, consent walls, A/B
tests and bot handling can change it. Storefront markup can change without
notice; the parser reports what it can and leaves unknown fields null.

## Limits

Automated gates prove what they exercise: host tests, container/emulator
journeys, artifact identity and API readback. They do not prove store review,
storefront propagation, installed-user availability, physical-device behaviour,
hardware-GPU performance, or the other lanes' qualification. A green pipeline is
a prerequisite for publication, not a substitute for the record.
