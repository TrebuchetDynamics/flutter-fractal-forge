# Gaussian bounded execution and retained exports — GAUSS-LOCAL-01

Local evidence, **not physical-device or human qualification**. Observed on
2026-10-25 UTC; `20261026` is the task's evidence-directory identity. Source
baseline: `0f97ccf25f0dfea380eef7b1f27335aaaa7c0814` plus the candidate hashes in
[manifest.json](manifest.json). The native receipt's revision is the pre-commit
HEAD, not a claim that the baseline already contained these changes.

## Observed result

- Focused model/walk command: **44 tests passed**, including real B=128
  cancellation across a suspended chunk, no stale publication, latest replacement
  publication, complete oracle membership, exact generation probe count and
  delayed B=128 UI radius/capture consistency.
- The elapsed-time regression deliberately stalls a cancellation predicate for
  at least 10ms just after clock reset. The next probe yields instead of waiting
  for 1,024 probes. Removing the elapsed-time branch failed this test (1 expected,
  1,024 observed); restoring it passed. This controlled stall is regression
  evidence, **not a measured natural scheduling delay**.
- Official Linux integration driver: **exit 0, protocol success true**. Owned
  cleanup: **no remaining PIDs**. Only sampled TCP listener: `127.0.0.1:20200`,
  inside this run's `20200..20299` allocation; Xvfb TCP disabled.
- Native journey uses the actual catalog, Walk, candidate selection, keyboard
  Step, growth/pause, and viewer HD export sheet. Retained
  [pre-walk.png](evidence/pre-walk.png) and
  [paused-growth.png](evidence/paused-growth.png) independently decode to
  **1280×720**, fully opaque, with **145,962 changed RGBA pixels**.
- [State](evidence/state.json) records B=32, 868 prime vertices, root `(1,1)`,
  pre-walk `k=4`/632 component vertices, and paused `k=8`/824 component vertices,
  selected `(1,-1)` and path `[(1,1),(1,-1)]`. The journey deep-compares the entire
  serialized painter/control state before/after each export, and again 1,300ms
  after paused export. Growth intentionally resets the path; Step then commits
  the selected edge again. Plot sizes differ between the two UI states, so the
  PNG difference is not attributed solely to the path. Export state equivalence
  is asserted separately for each snapshot.

## Named target and actual measurements

Host **BlueBlack**, Linux/Xvfb, Flutter **3.44.6** framework
`ee80f08bbf97172ec030b8751ceab557177a34a6`, Dart **3.12.2**, debug native app.
`FORCE_GPU_RENDER=true`; the app log records GPU backend selection, shader load
and a successful health probe. The same owned display's `glxinfo -B` reports
**Mesa 25.2.8 / llvmpipe (LLVM 20.1.2, 256 bits), Accelerated: no**. This GLX probe
names the available software backend, not an independent query of Flutter's
engine context or evidence of hardware acceleration.

[Raw native telemetry](evidence/telemetry.json) is a separate B=128 model pass
inside that application **after** the B=32 UI/export journey, not UI input-to-ready
latency. All times below are single-run wall-clock observations:

| Observation | Actual |
| --- | ---: |
| B=128 prime vertices / candidate positions | 9,476 / 66,049 |
| Generation (including yields) | 148,956 µs |
| Generation probes (sieve + lattice) | 126,000 |
| Budget-triggered yields / final tail probes | 123 / 48 |
| Largest observed work chunk | 4,036 µs |
| Observed work-chunk excess above 8ms | 0 µs (not a guarantee) |
| Largest zero-duration timer wait | 1,136 µs |
| Cancellation request to queue idle after releasing held yield | 177 µs |
| Cancellation yields / cancelled publications | 1 / 0 |
| Component k=1: vertices / search | 3 / 55 µs |
| Component k=2: vertices / search | 100 / 545 µs |
| Component k=4: vertices / search | 720 / 5,883 µs |
| Component k=8: vertices / search | 2,996 / 1,883 µs |
| Component k=16: vertices / search | 9,476 / 11,004 µs |
| Native process RSS before cap pass | 625,860,608 bytes |
| RSS after generation / after searches and diagnostics | 626,831,360 / 643,649,536 bytes |
| Process maximum RSS observed over its lifetime | 678,690,816 bytes |

The optional `GaussianPrimeMap.generate(onChunk: ...)` observer reports probe
count and elapsed chunk wall time. `yielded: true` identifies a budget-triggered
pause boundary; cancellation can short-circuit that pause before the await.
`yielded: false` identifies a successful generation's final tail. A probe is a
sieve-mark write, outer sieve iteration, or lattice-candidate predicate evaluation;
it is **not** a neighbor-search probe. Observer work and await scheduling are
excluded after clock reset. Wall time still includes OS preemption. The 8ms or
1,024-probe check is cooperative: neither a single probe, scheduling, nor a
zero-duration timer wakeup has a hard 8ms limit. Raw zero-timer wait times retain
actual scheduler delay instead of assuming immediate wakeup.

Current component search is **synchronous**, with no 8ms/1,024-probe chunk claim;
the measured k=16 search exceeded 8ms. This task preserves that implementation,
formulas, k≤16 and B≤128 caps. Search ordering, JIT warmup, GC, debug mode and
host load make the non-monotone timings unsurprising. RSS includes the complete
app, shaders, export allocations and telemetry, not model-only heap or GPU
memory. No per-chunk memory maximum, repeated-run distribution, production-mode
latency, physical GPU result or cross-platform performance guarantee was measured.

## Reproduce and reconcile

Use the pinned, already-provisioned SDK/cache; no package installation or SDK
modification. From the execution checkout with its own assigned `TMPDIR` and
`AUTOWORK_PORT_BASE` (do not borrow this historical allocation):

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile
flutter test --no-pub test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart --reporter expanded
flutter analyze --no-pub lib/core/models/gaussian_moat_model.dart test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart integration_test/flows/gaussian_moat_journey_test.dart
autowork-run timeout --kill-after=10s 960 bash scripts/run-native-integration.sh \
  integration_test/flows/gaussian_moat_journey_test.dart --timeout 900 \
  --dart-define=FORCE_GPU_RENDER=true --dart-define=GAUSSIAN_RETAIN_EVIDENCE=true
/usr/bin/python3 docs/qa/gaussian-local-20261026/verify.py
git diff --check
```

Without `GAUSSIAN_RETAIN_EVIDENCE=true`, the ordinary journey still asserts state
and PNG behavior but writes no retained diagnostic bundle. With it, the wrapper's
printed private evidence directory contains `outputs/gaussian/` (both PNGs,
state, telemetry), `run.json` and the official `protocol-success.json`. Export
scratch is deleted by the journey; retained copies survive in the wrapper's
outputs. The whole-run supervisor cleans up only its owned process group.

[verify.py](verify.py) uses Python's standard library, not the application's PNG
or primality code. It validates PNG chunk CRCs, inflates/unfilters all RGBA bytes,
checks dimensions/opacity/differences, reconstructs both finite components with
trial division/BFS, reconciles B=128 search sizes and generation probe totals,
and verifies source/artifact hashes, the official protocol result, allocation
and cleanup. It is a read-only historical-evidence check: source drift requires
review/rerun, not automatic receipt repinning. The manifest hashes all `lib/`
and `shaders/` bytes as well as the named target, harness, lockfile and tests.
The retained [driver log](evidence/driver.log) redacts the VM authentication
URL segment; its original hash is recorded, and the raw log stays private.
Trailing progress-line whitespace is removed from retained driver/analyzer logs.
GDK monitor/cursor and an OpenGL resize warning are retained, not hidden.

## Scoped Docs Sync Maintain / remaining qualification

Maintained: this task's QA owner, manifest, retained artifacts and executable
readback. Inspected unchanged: [Gaussian test plan](../../engineering/test-plan.md#gaussian-moat-visualization),
[workload specification](../../engineering/spec.md#workload-and-scheduling-limits),
and [native reserved-port runbook](../../engineering/runbook.md#owned-linux-runtime-with-reserved-ports).
No requirement/cap/policy was rewritten to turn an unmeasured criterion green.

Coordinator-owned documentation reconciliation remains: link this evidence from
the Gaussian test-plan section and replace its blanket B=128-native-telemetry
pending statement with this limited result. The historical specification's
planned k=100/search chunking and "files do not yet exist" text differ from the
current k≤16/synchronous-search implementation; this task records that distinction
without changing accepted formulas/caps or claiming the wider plan implemented.

**Not inferred:** Android install/MediaStore/gallery readback; physical hardware
GPU behavior; physical keyboard/screen-reader/accessibility journeys; complete
live responsive/localization coverage; browser requalification; human review of
mathematical composition. Original device/human-gated tasks are not closed or
recreated by this local evidence. No remote publication occurred.
