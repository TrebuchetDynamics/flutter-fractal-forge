# Quaternion local execution — QUAT-LOCAL-01

Retained local Linux/Chromium slice, walk and PNG evidence. **Not physical-device,
hardware-GPU, screen-reader or human visual/mathematical qualification.**
Authority: [local execution decision](../../tasks/UNBLOCK-20261026.md).
Related owners: [accepted checks](../../engineering/test-plan.md#prime-walking-growth-and-quaternion-slice-checks)
and [native protocol runbook](../../engineering/runbook.md#owned-linux-runtime-with-reserved-ports).

## Actual results

Observed on **BlueBlack, Linux**, 2026-10-26 UTC. The directory date identifies
this task. [Manifest](manifest.json) records source baseline
`9bddba8cb6a715eb31c4893bdb3645a0a6f0cae9`, the tested two-fixture patch,
1,030 source-input hashes, complete native/web build-file hashes and retained
artifact hashes. Receipt revisions name pre-commit HEAD; they do not pretend the
baseline already contained the fixture changes. No product/shader code changed.

| Check | Actual result |
| --- | --- |
| Named quaternion model/walk targets | **8 passed**, no skips |
| Changed Dart analyzer | No issues |
| Official Linux native driver | **1 journey passed** plus teardown (`+2`); exit 0, terminal `result: true`, empty failures |
| Owned native cleanup | `remaining_pids: []`; only sampled TCP listener `127.0.0.1:20200` |
| Fresh release web build | Exit 0; existing missing Cupertino font-family warning retained |
| Existing local Chromium project | **1 passed**, zero skipped/flaky/unexpected |
| Independent Pillow readback | Five original plot PNGs decoded; dimensions, content, state, source hashes and protocol reconcile |

### Coverage and state binding

**Native:** the existing fixture mounts **GaussianMoatMap directly**, opens its
quaternion companion, drags the plot, selects through Coordinate list, Steps,
returns to 3D and captures via the real callback. It is **not** a full app/catalog
journey. List mode disables Capture PNG with its explanation. Public painter
snapshots record the actual finite points/component/path/camera and control text;
export must leave that snapshot unchanged. Native window: **1280×720**, DPR 1;
owned Xvfb screen: 1280×800×24, TCP disabled.

**Browser:** the production release app is entered through the actual **catalog →
Gaussian Prime Lattice viewer → Walk → Quaternion slice** route, not an injected
companion. The fixture asserts actual list selection, disabled list capture,
Step and fixed-d component status, then retains original downloaded PNG bytes.
Viewport: **1280×900**, DPR 1. Browser state retains exact UI text and an ARIA
snapshot, not private Dart camera/path telemetry. Chromium **147.0.7727.15** runs
on Linux; the existing Desktop Chrome project emulates a Windows user-agent.
The original coordinate-based catalog entry/open checks remain; semantics select
and Step the actual row instead of trusting a changed screenshot after a tap.

Both runs use **B=6, d=0, squared step limit 2**, 572 prime-norm points and a
3-vertex component rooted at `(-6,-6,-5,0)`. Selecting `(-6,-5,-6,0)`, norm **97**,
then Step changes the path from zero to one edge of squared length **2**. Native
camera is yaw **0.192**, pitch **0.096**, unchanged across the compared captures.
The browser preserves its one-step/selected/component text across export and
rotation. With semantics enabled its pointer pan alone did **not** change the
plot export; the advertised **ArrowRight** keyboard rotation does. The stronger
PNG assertion caught this distinction. This is keyboard/software rotation
evidence, **not a successful physical pointer-pan claim**.

| Original plot bytes | Decoded size | Visible-alpha pixels | Distinct RGBA |
| --- | --- | ---: | ---: |
| [Native before walk](evidence/native/before-walk.png) | 1280×540 | 27,992 | 3,347 |
| [Native after walk](evidence/native/after-walk.png) | 1280×540 | 28,153 | 3,406 |
| [Browser before walk](evidence/browser/before-walk.png) | 1280×675 | 8,143 | 361 |
| [Browser after walk](evidence/browser/after-walk.png) | 1280×675 | 8,333 | 378 |
| [Browser rotated](evidence/browser/rotated.png) | 1280×675 | 8,514 | 1,540 |

Independent full-RGBA comparison finds **228 native walk**, **208 browser walk**
and **16,331 browser rotation** changed pixels, each on equal-sized plot captures.
Transparent backgrounds are intentional; these are plot-only exports, not UI
screenshots. The separate [rotated screen](evidence/browser/rotated-screen.png)
is a 1280×900 full-page capture. Numerical content/difference checks do not prove
human composition quality or complete mathematical pixel fidelity.

### Repaired capture-boundary regression

The old native pre-walk finder selected the first descendant RepaintBoundary,
which belonged to the header's scroll viewport (**659×180**), while the real
export captured the plot (**1280×540**). Its old pixel comparator accepted any
size mismatch as a difference. A same-size assertion failed on that finder;
the [red transcript](evidence/native/boundary-regression-red.log.gz) and receipt
are retained. The fixture now walks upward from the actual plot to its nearest
boundary and requires equal decoded dimensions before comparing pixels. It
passes without weakening the fixed-d/list/walk/export assertions. The sole
existing journey was extended; no redundant test or production hook was added.

## Build, backend and owned execution

Pinned Flutter **3.44.6**, framework `ee80f08bbf97172ec030b8751ceab557177a34a6`,
engine `83675ed27633283e7fc296c8bca22e841224c096`, Dart **3.12.2**. Native debug
executable, engine library, kernel and other bundle hashes are in the manifest;
the driver built and launched that bundle. The release web tree is independently
hashed, and [server receipt](evidence/browser/server.json) binds the bytes fetched
from the owned server's `main.dart.js` to the built file hash and fixture hash.

Actual allocation: **20200–20299**. Browser uses **127.0.0.1:20211**, with an unused
port preflight followed by an owned bound HTTPServer, `PLAYWRIGHT_SKIP_WEBSERVER=1`
and explicit local base URL. A preliminary attempt refused occupied port 20201;
that foreign listener was neither reused nor terminated. No remote public app
was used. The server shuts down/closes and joins its thread after Playwright.

`FORCE_GPU_RENDER=true` was supplied to native. The companion itself is a Flutter
CustomPainter, not a quaternion Julia shader or the formula CPU fallback. The
same owned native display's [GLX probe](evidence/native/glxinfo.txt) reports
**Mesa 25.2.8, llvmpipe (LLVM 20.1.2), Accelerated: no**. Browser's separate WebGL
probe reports **ANGLE/Vulkan SwiftShader**. These probes name available software
backends, not independent queries of Flutter's engine context or proof of
hardware acceleration. GDK monitor/cursor and OpenGL resize warnings remain in
the native transcript. Only expired VM authentication URL paths are redacted;
all other bytes survive gzip, with the raw log hash recorded. The GLX text copy
removes trailing empty lines only.

## Reproduce / independently read back

Use the assigned checkout, its own allocation/TMPDIR and already-provisioned
tools. Install nothing. No dependency or lockfile change is required:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile
flutter test --no-pub test/modules/prime_norm_quaternion_test.dart test/features/viewer/prime_norm_quaternion_walk_test.dart --reporter expanded
flutter analyze --no-pub integration_test/flows/prime_norm_quaternion_journey_test.dart

autowork-run timeout --kill-after=10s 960 bash scripts/run-native-integration.sh \
  integration_test/flows/prime_norm_quaternion_journey_test.dart --timeout 900 \
  --dart-define=FORCE_GPU_RENDER=true --dart-define=QUATERNION_RETAIN_EVIDENCE=true

autowork-run timeout --kill-after=10s 960 flutter build web --release --no-pub
export PLAYWRIGHT_BROWSERS_PATH="$AUTOWORK_CACHE/playwright-browsers"
export QUATERNION_EVIDENCE_DIR="$TMPDIR/quaternion-browser"
autowork-run timeout --kill-after=10s 300 /usr/bin/python3 docs/qa/quaternion-local-20261026/run-browser.py
/usr/bin/python3 docs/qa/quaternion-local-20261026/verify.py
git diff --check
```

Without `QUATERNION_RETAIN_EVIDENCE=true`, native still runs assertions but writes
no retained bundle. With it, the wrapper's printed private directory includes
`outputs/quaternion/`, `run.json`, official success callback and terminal response
log. Browser PNG/state files live under the declared output's `artifacts/`.
These task copies travel with the commit; scratch is not required for readback.
The full merged-tree offline gate belongs to the coordinator and was not run here.

[verify.py](verify.py) uses existing Pillow **10.4.0**, independent of Dart `image`
and browser ImageBitmap. It decodes all pixels, hashes RGBA, checks dimensions,
content and differences, reconstructs the finite component with trial division
and BFS, and checks state, source/artifact hashes, actual nonempty test aggregates,
local server/build identity, native terminal protocol and owned cleanup. It is a
historical-evidence readback: source drift fails, not silently repins receipts.

## Scoped Docs Sync Maintain / remaining limits

Maintained this QA owner against current fixtures, source, real output and
retained receipts; verified local links and executable readback. Inspected the
accepted quaternion test-plan/spec and reserved-port runbook. No role manifest
exists, so bundled Docs Sync `check`/`stale` report nothing to check; substantive
verification is the source/content/protocol/link readback above. No task-store,
shared history, policy, accepted formula or product cap was edited.

Coordinator/DOCS-MAINTAINER reconciliation remains: link this limited evidence
from the shared quaternion test-plan and reconcile its historical blanket
“planned/unrun” wording and the specification's “tests do not yet exist” wording
against current source. Do not convert these local results into all-platform
acceptance. This documentation follow-through is not a new hold or follow-up task.

**Still not measured/accepted here:** physical gestures/GPU, operator screen-reader
journeys, native Android storage/gallery readback, human mathematical/composition
verdicts, and broad platform/localization/performance distributions. Existing
focused tests cover EN/ES and enlarged/high-contrast layouts, not live assistive
technology. Original human/device-gated work is neither closed nor recreated.
No Android state change, package installation, remote publication or push occurred.
