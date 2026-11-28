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
| Run only the shared offline gate | [Provisioned common offline command](../../../AGENTS.md#common-offline-integration-gate), ending in `scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 --json` |
| Run only the Android device gate | `scripts/pre-release-gate.sh --device <id> --disposable-device <id>` |
| Prepare every independent lane | `./release.sh --best-effort --prepare=X.Y.Z --build-number=N` |
| Publish those prepared lanes | `./release.sh --best-effort --publish=X.Y.Z --build-number=N` using the same frozen campaign/artifact paths |

`scripts/release-play.sh` is the Play-only path. It is *fail-closed*: no gate, no
upload; a failed readback never triggers a second upload. The lane campaign is
the multi-platform path and keeps its own per-lane evidence contract. Both campaign invocations require `--best-effort`; optionally set the same `--artifact-dir` and `--campaign-file` on both. The bare root `./release.sh` (even with `--target play`) dispatches `scripts/gitlab_release.py` and remains deferred. It is not a Play-only shortcut. Play defaults to production/completed; internal testing/draft requires an explicit nonproduction request and override.

## Play pipeline stages

`scripts/release-play.sh` runs these stages in this order. Each row states what
the stage actually proves and what it does not.

| Stage | Command it runs | Proves | Does not prove |
| --- | --- | --- | --- |
| 1. Identity preflight | git/`fdroid/version.properties`/`pubspec.yaml` checks | the requested version matches the committed identity, the tree is clean, and an existing tag does not point elsewhere | that the version code is free on Play |
| 2. Play preflight | `scripts/ci/play-status.sh` (or `--play-status-json`) | the version code is unused and newer than the latest consumed code | that Google accepted anything |
| 3. Shared offline gate | `scripts/ci/offline-gate.sh` | pinned SDK, unchanged `pubspec.lock` and `rust/Cargo.lock`, cargo fmt, warning-denying clippy and locked/offline Rust tests, analyzer, Flutter host tests, Python tests, Bats tests | device, browser, GPU, store or review behaviour |
| 4. Device gate | `scripts/pre-release-gate.sh --skip-host` | install/journey/rendering/accessibility/performance/restoration/offline/soak on the designated target | physical-device or hardware-GPU qualification |
| 5. Build + upload | `scripts/build-upload-playstore.sh` | a signed AAB with the expected version code/hash was uploaded to the requested track and the edit committed | review outcome or storefront propagation |
| 6. Readback + evidence | `scripts/ci/play-readback.sh`, then evidence files | a fresh edit reports the exact version code, hash, track and status | end-user availability |

Stage 3 and 4 can be skipped only by explicit flag, and a skip is written into
the evidence file as `skipped`. Skipping is a recorded gap, never an implicit
pass.

### Publication states and retry boundaries

Qualification, publication, review and storefront propagation are separate states.
The wrapper does not infer one state from another.

| From | Event and guard | Result | Recovery |
| --- | --- | --- | --- |
| Prepared | Identity matches and version code is unused | Run qualification gates | A gate failure stops before upload |
| Gates completed | Requested gates passed, or an explicit skip remains recorded as a gap | Attempt upload and commit once | A lost response can mean publication is unknown |
| Publication unknown | Uploader or readback fails after a write may have occurred | Exit 1, no automatic reupload | Reconcile exact remote version/hash before any retry |
| Awaiting readback | Fresh response has the requested track, status, code and hash | Publication confirmed | Storefront and review remain unobserved |
| Any readback | Missing track identity or malformed resource | Unknown, not confirmed absence | Stop; do not authorize a publisher from this result |
| Publication confirmed | Run the separate observer/checker | Report observed review and propagation states | Pending propagation never triggers another upload |

Successful evidence records `state.publication=confirmed`. Review, storefront
propagation and end-user availability remain `not_observed` until separate
observations exist. A confirmed API operation is not an end-user availability
claim. An upload error exits 1, not the exit-2 prepublication-refusal state.

The wrapper has no automatic resume or cross-process publication lock. It does
not make the standalone uploader safe to retry after an ambiguous remote write.
Serialize publishers and retain receipts. This map covers the Play wrapper and
readback, not every campaign or listing mutation. The scoped review also found
unresolved uploader boundaries: no expected artifact-hash precondition, mutable
listing inputs after validation, conflicting legacy/localized title inputs, and
no durable intermediate upload/commit journal. These are source-supported risks,
not observed failures in the 124 publication. They need separate uploader
mutation/crash-window tests before a claim of safe automatic retry.

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
| `FLUTTER_ROOT`, `PUB_CACHE` | `$AUTOWORK_CACHE/flutter-3.47.9`, `$AUTOWORK_CACHE/pub-cache`; SDK must match [`fdroid/flutter.version`](../../../fdroid/flutter.version) | offline gate, builders |
| `CARGO_HOME`, `RUSTUP_HOME` | `$AUTOWORK_CACHE/cargo-1.95.0`, `$AUTOWORK_CACHE/rustup-1.95.0`; existing Rust 1.95.0 toolchain on `PATH` | Cargo stages of the offline gate |
| `TMPDIR` | existing scratch base outside the checkout; Play wrapper creates a private child | offline gate, campaign builder |
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

Use the [common offline setup](../../../AGENTS.md#common-offline-integration-gate) and its version/Python-import probes before release commands. Its cache defaults to the absolute Git common directory, not a guessed home SDK path. The following environment is process-local; run it in the same subshell as the selected authorized command. Missing provisioned tools/cache is a refusal: install nothing, change no pin and do not fall back to ambient tools.

```bash
export AUTOWORK_CACHE="${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}"
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"
export RUSTUP_HOME="$AUTOWORK_CACHE/rustup-1.95.0"
test -x "$FLUTTER_ROOT/bin/flutter" && test -d "$PUB_CACHE" &&
  test -x "$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/cargo" &&
  test -d "$CARGO_HOME/registry" || exit 2
export PATH="$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:/usr/bin:$PATH"
export TMPDIR=/path/outside/checkout
export PLAY_SERVICE_ACCOUNT_JSON="$PWD/play-console-upload/play-service-account.json"
export ANDROID_DEVICE=192.168.240.112:5555
export ANDROID_DISPOSABLE_DEVICE="$ANDROID_DEVICE"
waydroid adb connect
adb devices -l
```

The offline gate is local host evidence only; omitted later stages after a failure are NOT_RUN. Android's device-changing gate is not an offline substitute. For reserved-port Linux integration use [the native wrapper recipe](../runbook.md#owned-linux-runtime-with-reserved-ports) and its real allocation/protocol/cleanup receipts; local `flutter test integration_test/` does not supply them.

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
| `pubspec.lock or rust/Cargo.lock changed during …` | dependency metadata drift | stop and investigate; preserve the committed locks, do not publish |
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

The wrapper creates gate logs in a private scratch directory **outside the
checkout**, even when the artifact archive uses its checkout-local default.
The logged `gate evidence dir`, evidence JSON `gate_evidence_dir`, and record
stub identify that directory. Child tests use the same private `TMPDIR`.
The `gates/` tree above is in that external directory, not the artifact archive.
Retain both directories before temporary-directory cleanup.

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

The campaign's `scripts/generate_release_evidence.py` collects hosted dependency
licenses from `PUB_CACHE` (default: `~/.pub-cache`). It resolves path-package
licenses through the checkout's `.dart_tool/package_config.json`, generated by
locked `flutter pub get`. Each resolved package must contain its license text;
missing metadata or licenses fail evidence generation. Keep the same package
cache and checkout-local resolution used by the offline gate. Do not copy
licenses into the ambient cache or omit dependencies to bypass this check.

Play is the one lane with a dedicated single-command wrapper because it is the
only lane whose destination is configured locally end to end. The wrapper does
not replace the campaign; a campaign run still validates and publishes its own
Play lane, and mixing the two on the same version code will be refused by the
consumed-code check.

## Release ritual

1. Decide the version code from `scripts/ci/play-status.sh`, not from memory.
2. Commit `fdroid/version.properties` + `fastlane/metadata/android/en-US/changelogs/<build>.txt`,
   plus identical F-Droid copies `<build>1.txt`, `<build>2.txt` and `<build>3.txt`.
3. `scripts/release-play.sh --dry-run --play-status-json <status.json>` to see the
   plan and the version-code verdict without touching anything.
4. Run the real pipeline; keep the artifact directory.
5. Copy `PLAY_RECORD_STUB.md` into a `PLAY_<version>.md` record, fill in the
   prose, and commit it together with any release-identity change.
6. Update the "Current release status" pointer in [MULTIPLATFORM.md](MULTIPLATFORM.md).
7. Push. Then run `scripts/ci/play-observe.sh` and `scripts/ci/play-live-check.sh`,
   and attach both JSON files to the record. See [OBSERVABILITY.md](OBSERVABILITY.md);
   review and per-device availability stay separate observations.

## Observing the live release

Publication is not the end state. The latest cited receipt is [Play 1.1.125](PLAY_1.1.125.md), production/completed code 125 from `6f63c28b`. At 2026-11-20T05:05:45Z propagation was still pending (12/12 storefronts showed 1.1.124); this is a dated observation, not a live status claim or instruction to reupload. Other lanes were not requalified. Two scripts cover the post-release checks. The following **historical 1.1.121 / 2026-11-06 example** is not the current release identity; use the actual receipt's version/date and private output path for a new authorized observation:

```bash
# Record track state, review (Console page or inference), propagation and availability.
scripts/ci/play-observe.sh --expected-version 1.1.121 \
  --expected-date "Nov 6, 2026" --output release-artifacts/play-1.1.121/play-observe.json

# Apply pass/fail policy to a saved observation (or run the observer first).
scripts/ci/play-live-check.sh --input release-artifacts/play-1.1.121/play-observe.json \
  --expected-version 1.1.121 --require-review approved
```

`play-live-check.sh` exits 0 only when the track is completed, the version is on
the track, enough storefronts list the app, no probe failed, propagation matches
and, when requested, the Console review state is `approved` or `published`.

Read [OBSERVABILITY.md](OBSERVABILITY.md) for the observable signals, JSON shape,
review-session options, exit codes, evidence paths and limits.

## Limits

Automated gates prove what they exercise: host tests, container/emulator
journeys, artifact identity and API readback. They do not prove store review,
storefront propagation, installed-user availability, physical-device behaviour,
hardware-GPU performance, or the other lanes' qualification. A green pipeline is
a prerequisite for publication, not a substitute for the record.
