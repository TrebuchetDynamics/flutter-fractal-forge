# Google Play candidate: 1.1.125 (125) — blocked

**Nothing was uploaded or published.** The last live Play preflight reported
production/completed 1.1.124 (124). Build/upload, publication readback and
storefront observation were not reached for 125.

## Source and repaired failure

- Candidate: `67eb5cf607a3176ce403668356605778193533cd`, isolated branch
  `release/play-125`; release preparation commit `536cfb60`.
- Application changes include viewer export-state guards and GPU-health probe
  confirmation from `04401d3d`.
- The initial offline gate failed two migration source-binding assertions.
  Repair `67eb5cf6` appends the scoped viewer-export maintenance successor and
  distinguishes historical bindings from current terminal bindings. It is also
  integrated locally as `2edb2340` on `fix/viewer-export-state-guards`.
- All 52 pre-existing migration evidence/lockfile hashes remained unchanged.
  Focused migration checks passed 20 tests; viewer/GPU regressions passed 225.
  Seven migration modules passed individually twice; both exports contained
  exactly 12 observations, matched all 11 complete candidate maps and were
  byte-identical. Export evidence: `/tmp/play125-exports-39tNPQ/`.

## Final qualification result

Two subsequent complete offline gates passed all eight stages: Rust fmt/clippy
and 127 tests; analyzer with no issues; Flutter 3569 passed, 9 skipped; Python
682 passed, 1 skipped, 204 subtests passed; Bats 34 passed. Both lockfiles stayed
unchanged.

On the designated Waydroid target `192.168.240.112:5555`, model
`WayDroid x86_64 Device`, boot complete, the combined device suite passed 12 tests
with 8 skips. Runtime-thumbnail performance and offline journey passed one test
each; production APK installation and restoration passed.

The full 300-second soak failed twice: only 6, then 4 cumulative Android View
frames, below the unchanged maturity requirement of 10. Exact error:
`Soak did not produce a mature janky-frame percentage sample.` Between these
attempts, exclusive existing-session stop/start succeeded and actual ADB/model/
boot readiness was reverified. No container restart/reset or threshold change
occurred. No further automatic retry was made.

Final soak PSS was 132075 to 202753 KiB (growth 70678 KiB), with zero crash/ANR
markers. Raw thermal samples were zero, but thermal validation was not reached.
These observations do not qualify performance or authorize bypassing the failure.
Waydroid remains container evidence, not hardware-GPU/physical-device evidence.

## Retained attempts and next action

Private host-local evidence, to retain before temporary-directory cleanup:

1. Initial migration failure: `/tmp/play-125-private-B5ObDs/`.
2. First immature-frame soak: `/tmp/play-125-retry-private-ABdQkl/`.
3. Session recovery and final immature-frame soak:
   `/tmp/play-125-final-private-dQaBOd/`; full output `pipeline.log`, gate logs
   `release-play-1.1.125-30ahuw/gates/`.

Next action: diagnose why the production soak's Android View-frame telemetry
remains immature after session recovery. Preserve maturity/jank/duration limits;
rerun the full release pipeline only after a supported repair. No AAB publication
hash, Play edit receipt or current-candidate review/propagation result exists.
Other platforms and GitLab were untouched; no remote Git push is claimed.
