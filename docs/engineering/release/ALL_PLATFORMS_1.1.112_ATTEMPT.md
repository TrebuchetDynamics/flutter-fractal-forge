# All-platform 1.1.112 attempt — 2026-10-26

## Result: failed release attempt; no new publication

The user requested Git commit/push and release across all platforms. The parent
verified origin/main at `a28aa567dabcd5ee8e4798475c1ff984236afc4d` before this
isolated attempt. This worktree did not push any ref, create/move a tag, use
GitLab, modify the task queue/services, install packages, or publish externally.
Two real release archives were built and verified. **Zero of seven lanes could
be admitted; zero publishers were called.** The observation's terminal exit is
**1**, not an all-skipped success. No publishable campaign was manufactured.

The owner's removal of 22 backlog tasks is backlog cleanup, **not a waiver of
any technical qualification**. Device, hardware-browser, human-review, signing,
source/evidence and native-platform gates remain intact. The active shared
Android app and its data were preserved: only device inventory was read; no
installation, uninstall, reset, profile change or device test occurred.

## Source and fresh identity

- Frozen source: `a28aa567dabcd5ee8e4798475c1ff984236afc4d`. Later canonical-main
  work was not injected into these builds.
- Candidate build identity: **1.1.112 / 112**, selected after live readback,
  **not uploaded, tagged or reserved** by this attempt.
- Live Play inventory: production release `Fractal Forge 1.1.111 (111)`, API
  status `completed`; bundle/APK plus all-track inventory maximum **111** (no
  standalone APKs; production, beta, alpha, internal and march inspected). The exact previously
  uploaded 111 AAB was independently confirmed with `found: true`,
  `conflict: false`, SHA-256
  `a1e27a4bad1df4ddbdf938badcb35d72f54d61e8ef6c4befbf10400ac9255fee`.
  The inventory reused the existing readback's OAuth/temporary-edit lifecycle,
  listed bundles/APKs and all tracks, then deleted the uncommitted edit. It
  did not upload or commit an edit. No storefront/review/availability verdict
  follows from API `completed`.
- Origin numeric tag maximum and latest published GitHub release: **v1.1.104**;
  live web `/release-identity.json`: **1.1.110 / 110**, source
  `e0079934bcad2b2a14af2599d07dbe484ee9cfe3`, 630 manifest files. This is identity
  readback only, not a fresh full served-asset or hardware-browser qualification.
  Existing recovery URL remains <https://fractal.trebuchetdynamics.com/view>.
- Canonical local Play build marker: 106; tracked F-Droid marker: 1.1.110/110.
  The latter was not changed on the frozen source. A future release must update
  the marker and matching base-build changelog together, freeze/recheck that
  candidate and reconcile live consumed identities again; 112 is not a lease.
- Flutter **3.44.6**, framework `ee80f08bbf97172ec030b8751ceab557177a34a6`,
  Dart **3.12.2**. `AUTOWORK_CACHE` was absent; actual existing provisioned paths
  `/home/xel/tools/flutter-3.44.6` and `/home/xel/.pub-cache` were selected with
  pinned Flutter and `/usr/bin` first on process-local PATH.
- Lockfile SHA-256 before and after checks/builds:
  `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
  Checkout-local dependency metadata was regenerated offline with the enforced
  lockfile. Source/lock identity remained unchanged throughout execution.

## Actual commands and checks

All paths below are relative to the execution worktree. Retained evidence root:
`release-artifacts/all-platform-20261026/` (ignored, private parent directory).
Full shared and build output is in `stage-logs/`; regression/readback output is
in `logs/`. Stage JSON records commands, exits and elapsed time.

| Executed command / existing function | Exit and observed result |
| --- | --- |
| `flutter --version`; `/usr/bin/python3` provisioned pytest/Jinja2/MarkupSafe import check | 0; pinned SDK/Dart and Python 3.12.3 imports verified |
| `timeout 300 flutter pub get --offline --enforce-lockfile` | 0; checkout-local metadata regenerated, lock unchanged |
| Existing `scripts/release_platform_lanes.py:common_gate`, invoked directly with frozen identity and retained stage output | 0; privacy/source integrity passed; `flutter analyze --no-pub` clean; `flutter test --no-pub`: **3,048 passed, 8 skipped** |
| `timeout 600 /usr/bin/python3 -m pytest test/research test/scripts -q` | Initial exit 1: 4 failed subcases, 294 passed, 1 skipped, 99 subtests passed. Environment-corrected rerun exit 0: **294 passed, 1 skipped, 103 subtests passed** |
| `timeout 300 bats test/scripts/*.bats` | Initial exit 1: 22 passed, 3 failed. Environment-corrected rerun exit 0: **25 passed** |
| `timeout 300 /usr/bin/python3 test/scripts/test_release_platform_lanes.py` | 0; **18 tests passed**, regression fixtures only, not live qualification |
| `scripts/ci/play-readback.sh 111 <exact-prior-AAB-hash>` plus sanitized bundle/production and extended bundle/APK/all-track inventories using its existing lifecycle | All 0; exact prior upload preserved, maximum observed consumed code 111 |
| `git ls-remote origin 'refs/tags/v1.1.*'`; `gh release list --limit 100 --json tagName,publishedAt,isDraft,isPrerelease` | Both 0; newest numeric tag/release 104 |
| `curl -fsS --max-time 30 https://fractal.trebuchetdynamics.com/release-identity.json` | 0; historical deployment identity 110/e0079934 read back |
| `adb devices -l` | 0; only attached target `192.168.240.112:5555`, WayDroid x86_64, shared/active; not a physical-device pass |
| `bash scripts/release.sh web-build --prepare=1.1.112 --build-number=112`, existing coordinator local-stage environment, bounded to 1,200 seconds | 0; release web archive/provenance produced |
| `bash scripts/release.sh linux --prepare=1.1.112 --build-number=112`, same supported local-stage environment and timeout | 0; native Linux release archive/provenance produced |
| `bash scripts/run-native-integration.sh integration_test/flows/user_flows_test.dart --timeout 600 --dart-define=FORCE_GPU_RENDER=true` | **2**, before launch: `AUTOWORK_PORT_BASE must reserve 100 non-privileged ports within 1024..65535` |
| Archive/provenance/hash/source validation | 0; both exact archives readable, no unsafe paths/links; web manifest and all **634** file hashes match; Linux executable is ELF64 |
| Terminal observation generation | **1**; all seven explicit terminal lane rows, zero admitted/published |

The initial regression failures are retained, not suppressed. A checkout-local
`TMPDIR` violated the Python fixture's explicit outside-repository assertion;
exported `FLUTTER_BIN` made three Bats fixtures use the real SDK rather than their
mock. Reruns changed only process environment: private scratch under Git common
`.git/private-release-all-20261026/scratch`, and unset `FLUTTER_BIN` for the
regressions while retaining pinned PATH. No tests, source, SDK or assertions were
modified. The check families ran separately, not as one falsely reported passing
literal shell chain.

### Why the full prepare/publish CLI was not run

The supported `./release.sh --best-effort --prepare=1.1.112 --build-number=112`
automatically enters unsafe/unavailable lane qualification here:

- Its Android route invokes `pre-release-gate.sh`, whose production install
  helper first **uninstalls** the production package (lines 115–130). The only
  attached target is shared with another active verifier. No safe independent
  device/profile was available; configured signing/service-account file presence
  is not the missing prerequisite.
- Its web adapter binds default ports 4173–4272; there was **no current port
  allocation**. Linux's old `flutter test -d linux` adapter also lacks supported
  raw VM listener binding. The supported reserved-port driver demonstrably
  refused the missing allocation before launching anything.

The supervisor explicitly authorized the mandatory offline gate's ordinary
host-test/regression listeners, **not** actual browser/native/device listeners.
No expired allocation was borrowed, port range invented, SDK patched, or guard
weakened. Existing common-gate and build-stage functions were instead executed
independently. No `--publish` was invoked: builds cannot replace missing
qualification, and the hardware-browser gate is additional to automated web
checks. No subset evidence/SBOM intended for publication was generated because
there was no admitted subset. `observed-results.json` is explicitly an
observation, **not an accepted `--publish` campaign or qualification receipt**.

## All seven terminal lane verdicts

| Lane | Build / artifact | Current qualification | Publication / terminal state |
| --- | --- | --- | --- |
| Android / Play | Not attempted: no safe independent device path | Shared app protected; destructive coordinator route not run. Current device/gallery/accessibility/saved-state and physical-target proof unavailable | Not attempted; **skipped-unavailable**. Prior 111 confirmed, never rebuilt/reuploaded |
| F-Droid | Not attempted | Official `fdroid` CLI absent; reproducibility/source scan and relevant Android qualification unavailable; maintainer acceptance separate | Not attempted; **skipped-unavailable** |
| Web / Cloudflare | Release archive and provenance/hash inventory passed | Actual browser journey and saved-data checks unavailable without an allocated server port; normal hardware-browser smoke absent. Wrangler absent on selected PATH; no provider change attempted | Not attempted; **skipped-unavailable** |
| Linux / GitHub | Native release archive and provenance passed | Supported driver exit 2 before launch; no current full journey receipt, retained edited-image comparisons, EN/ES/inspired-entry coverage or attributable human review | Not attempted; **skipped-unavailable** |
| Windows / GitHub | Not attempted: no supported Windows host/executor configured | Native journey/export and packaging/download validation unavailable; no Linux/Wine substitute | Not attempted; **skipped-unavailable** |
| macOS | Not attempted: no Darwin/Xcode host | Native journey, signing/notarization and approved qualified production distribution unavailable | Not attempted; **skipped-unavailable**; no unsigned archive called a release |
| iOS | Not attempted: no Darwin/Xcode host | iOS journey, signing/provisioning/store prerequisites and approved store publisher unavailable | Not attempted; **skipped-unavailable**; no submission/store availability claim |

## Immutable build artifacts and evidence

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `fractal-forge-web-v1.1.112.tar.gz` | 22,698,970 | `9d48bc6713d90193d203e8794469b3ead3c9fd567b04b950155bce790278af94` |
| `fractal-forge-linux-x64-v1.1.112.tar.gz` | 21,769,197 | `565395c0bd96847c1fc1f49c4c3f02d31aab666ce0b5f5307172bb18c70813c5` |

Both provenance sidecars bind version/build/source/hash. Web archive: 720 members,
635 regular files including its identity manifest, 634 content hashes verified.
Linux archive: 684 members, 603 regular files, ELF64 executable. Neither contains
links or unsafe archive paths. Build output retains a missing CupertinoIcons-font
warning; compilation alone does not establish icon/font or visual quality.

Also retained: `identity.json`, `source-file-hashes.json`, `lane-inventory.json`,
`common-gate-result.json`, `web-artifacts.json`, `linux-artifacts.json`,
`archive-validation.json`, `observed-results.json`, `progress.md`, all initial and
corrected regression logs, remote inventories, and native-driver refusal output.
`evidence-SHA256SUMS` binds retained non-scratch evidence files; it is not a
publication manifest. Credentials were neither printed nor copied into evidence.

## Next inputs

Provide a legitimate release execution allocation, an install-safe independent
Android target and required physical/gallery/accessibility qualification, actual
hardware-browser smoke, Linux retained-image/coverage/human verdicts, official
F-Droid tooling, and supported native Windows/Apple hosts plus signing/store
qualification through existing approved routes. Reconcile live identities and
prepare matching tracked release metadata before freezing a new candidate.
Retain the current 110 web deployment and 111 Play upload; do not duplicate them
or publish empty GitHub releases. Parent review/integration/push of this factual
report is separate from app-source Git delivery and external release publication.
