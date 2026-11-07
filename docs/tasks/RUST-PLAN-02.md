# Rust migration next batch

## Authority and scope

This is the delegated completion of `RUST-PLAN-02`, Plan round: 1 of 10.
It refines the [accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
under `RUST-ENGINE-001`. It does not accept a new product direction, qualify the
goal, grant live authority or start implementation. The goal remains unmet.
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain binding. Terms follow the [migration glossary](../engineering/GLOSSARY.md).

User outcomes: keep Flutter as the working presentation/platform shell, move all
mathematical and rendering ownership to Rust in stages, preserve saved data and
mathematical claims, prove native composition, then finish Web and Dart retirement.
Non-goals: new fractals/UI, publication, host upgrades, a second app or repository.
Anti-goals: dual mutable state owners, lossy exact integers, invented CPU support,
frames copied through Dart, or treating build success as installed/native proof.

All choices below are planner calls within that scope, not new owner decisions.
No application, test, fixture, generated glue, manifest or CI file changes in this
planning pass. The older shared plan remains unchanged; this supplement holds the
next batch and its remaining-proof map.

## Evidence read and milestone disposition

Inspection base: `3a91677b1312946426ccfd9d5206f98c02656647`.
The five prerequisite task records are `done`, with `coordinator_verified` closure
and references under `tasks/evidence/`. Preserve those closures and contracts.
Read the actual finished reports in place under the execution common directory:
`.git/autowork-execution/slot-data/` in the canonical repository, not this
worktree's `.git` file. No reports are copied into this plan.

| Task / report | Actual implementation evidence | Limit |
|---|---|---|
| RUST-M0-CONTRACTS, attempt-1/report.json, `7e56bc8d` | Five schema-1 inventory envelopes, deterministic exports, 19 focused tests. `test/migration/support/baseline_inventory.dart` preserves separate module/catalog IDs, order, exact decimal strings, claims and source hashes. | Debug/test registry includes diagnostics. Custom setter ABI remains unresolved. This is not a release-mode inventory or wgpu ABI. |
| RUST-M0-REPLAY, attempt-1/report.json, `0cf68df2` | 68 ordered state events and 81 precision events, 38 focused tests, byte-identical repeat exports. | Dart oracles, not Rust parity or numerical precision certification. |
| RUST-M0-IMAGES, attempt-1/report.json, `9f38158f` | Eleven real states in two retained captures, 12 tests per capture, 19 health/reference tests. All eleven same-backend pairs have zero changed pixels. | Linux Flutter tester software readback only. Earlier black Burning Ship capture remains failed history; RUST-M0-SHIP-REPAIR preceded the successful captures. No cross-GPU tolerance or mathematical qualification. |
| RUST-M1-WORKSPACE, attempt-2/report.json, `e59efc24` | Three nonpublishable crates, Rust 1.95.0, offline fmt/clippy/tests, dependency-boundary negative check and local CI script. | Hosted workflow not dispatched; no native journey. |
| RUST-M1-BRIDGE, attempt-2/report.json, `8d7b547d` | FRB Rust/Dart/codegen 2.11.1, four Rust tests, 51 migration/logging cases, repeat generation equality, Linux/Android smoke builds, both Web flag builds. | Installed Linux/Waydroid probe is explicitly unrun. Browser runtime, GPU and timing remain unqualified. |

M0's contracted offline baseline is delivered. It remains an oracle with the
limits above, not proof of later migration gates. M1's offline foundation is
delivered; **M1 is still pending installed Linux and Waydroid lifecycle proof**.
The current `Engine` in `rust/crates/fractal-bridge/src/api.rs` owns only an atomic
closed flag. `RustEngineAdapter` creates a probe, not controller state.
`integration_test/migration/rust_engine_smoke_test.dart` already asserts version
`0.1.0`, `rendering == false`, independent handles, duplicate shutdown and closed
reads. Reuse this fixture, rather than invent another probe or rebuild M0.

The final bridge report supersedes earlier resolver/logging repair proposals.
`RUST-M1-BRIDGE` is closed; stale next-action/review notes are history, not an
instruction to reopen it or replay omitted candidate task edits. No saved ledger
patch is an input to this planning trigger. The source-bound final report and
current closure, not an earlier proposed patch, define the starting point.

## Next executable batch

Four new tasks total, all under `RUST-ENGINE-001`:

| Task | Outcome | True prerequisites | Placement |
|---|---|---|---|
| RUST-M1-LINUX | Run and retain real Linux probe/lifecycle results through the owned reserved-port driver. | RUST-M1-BRIDGE provides native glue and smoke fixture. | Now, below the owner's existing first task. |
| RUST-M1-WAYDROID | Run and retain the same real probe on the designated Waydroid target. | RUST-M1-BRIDGE provides the Android library and fixture. | Now, below the owner's existing first task. |
| RUST-M3-CATALOG-PARITY | Add a read-only, typed Rust catalog baseline reader and complete payload parity tests. No runtime registry switch. | RUST-M0-CONTRACTS provides the data; RUST-M1-WORKSPACE provides the crate boundary. | Now, below the owner's existing first task. |
| RUST-PLAN-03 | Plan the next ownership batch from all three results and this complete remaining-proof map. Plan round: 2 of 10. | Every new building task above. | Next. |

Why this cut: collecting native proof first is required before admitting a runtime
state-owner switch. Read-only catalog preparation can progress independently:
parameter normalization will need descriptor types/defaults, exact values and IDs.
This is M3 preparation, **not** M3 completion ahead of M2. Reject a whole-controller
port in this batch: the bridge has no command/snapshot seam yet, Number Walls has
asynchronous certification, and two native runtime checks remain unexecuted.
Reject waiting for hardware timing before any pure domain work: ADR 0006 separates
those claims. Do not add a dependency on ACAD-013-4142ef42 merely because it uses
Waydroid; it is not a producer of the Rust fixture. Device contention is admission,
not a product prerequisite. Do not modify that task or its priority.

### Closed implementation choices

- Linux uses the existing wrapper and official integrationDriver response, not
  `flutter test -d linux` or an app log that says tests passed. Require real worker
  `AUTOWORK_PORT_BASE` and private `TMPDIR`. Missing allocation is a setup refusal,
  not an invented coordinator receipt. Retain `run.json`, `driver.log` and terminal
  protocol output outside disposable scratch, linked from the task evidence note.
- Waydroid uses its existing standing target consent and matching
  `ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE`. Rediscover the IP, check native
  model `WayDroid x86_64 Device`, boot and actual `get-state`. Follow the existing
  transport diagnosis. Coordinate current workers; no reset, unrelated deletion,
  new target, container restart or key/credential changes in this task. An exact
  transport/permission failure remains failure. No physical-phone question.
- Each native task owns a separate `docs/tasks/<task>.md` result note. It records
  revision, relevant source/build hashes, SDK/Rust/FRB identity, exact command,
  backend/target, terminal outcome, cleanup and remaining claims. These notes are
  test evidence, not owner qualification or coordinator receipts. Existing smoke
  assertions and default-off behavior must not be weakened. A shared mutable
  Waydroid target uses the live resource under its existing consent; Linux uses
  isolated owned processes and its worker port lease. No execution occurs here.
- Catalog preparation consumes the four existing `modules`, `parameters`,
  `presets` and `capabilities` schema-1 envelopes. Add `CatalogBaseline::from_jsons`
  taking four JSON strings and returning `Result<CatalogBaseline, CatalogError>`
  in `fractal-core`. Typed accessors distinguish module and catalog IDs, parameter
  kinds and exact decimal strings. Keep all original payload fields and order
  metadata for semantic round trips, including presentation literals and claims.
  This is not an opaque JSON-only wrapper or a live registry authority.
- Use serde/serde_json for this bounded reader, with exact-number preservation;
  pin the resolved graph in `rust/Cargo.lock` in an isolated cache. Exact patch
  selection is worker-reversible. Do not write a new JSON parser or normalize
  decimal strings through f64. Reject wrong schema/kind, malformed JSON, duplicate
  IDs and broken cross-envelope module references without partial publication.
  Do not invent runtime precision, primality validation or new preset semantics.
- Read the original baseline files directly in Rust tests; do not create a second
  copied fixture set. Compare every payload semantically and preserve every
  existing value/type; byte-identical Rust/Dart pretty-printing is not required.
  Add focused mutation cases for a missing module, enum value and exact decimal.
  The existing core dependency test currently permits only the local foundation
  graph. Extend it to the actual locked pure-domain serde graph, retaining a
  negative UI/platform-dependency test. This necessary check repair is in scope.
  Update the spec's current local-only dependency/status description to the actual
  pure-domain graph and read-only API; its runtime ownership boundary stays intact.
  No FRB dependency enters core/render. No production routing, shader ABI claim,
  M0 fixture repinning, saved-data migration or codegen change belongs here.

## Remaining proof map

Every original phase remains required. A task closure does not waive its gate.

| Gate | Remaining proof after this plan |
|---|---|
| M0 | Preserve inventory, replay and two real reference captures, including debug/diagnostic mode and unresolved setter limits. Recheck or explicitly review refreshes when semantic inputs change. |
| M1 | RUST-M1-LINUX and RUST-M1-WAYDROID supply installed/native version and handle lifecycle evidence. Builds, mocks and cargo tests do not substitute. |
| M2 | Rust sole-owner full session transactions, physical-input-to-camera semantics, typed parameters, immutable snapshots, engine/session IDs and monotonic u64 revisions. Consume all replay sequences, preserve last-good state, asynchronous Number Walls certification and stale-work rejection. Legacy Flutter renderer consumes snapshots only for migrated sessions; all other sessions stay Dart-owned. |
| M3 | After read-only parity, move runtime registry/catalog/preset/capability semantics. Prove production/debug/performance and hidden-card distinctions, order, exact decimals, provenance and presentation mapping. Debug baseline alone does not qualify release filtering. |
| M4 | Rust uniform mathematics and versioned family binding manifest. Compare actual float values and separate samplers; keep transparency semantics. Unresolved custom setters cannot be certified from declarations. |
| M5 | Precision ladder boundary neighbors, history/hysteresis and actual capability/power parity. No invented CPU precision; retain navigation versus perturbation ceilings. |
| M6 | Existing supported CPU formulas, analytic classification/RGBA parity, bounded tiles/jobs/memory, cancellation and off-UI execution. |
| M7 | Reference orbits, double-float/arbitrary precision, coordinate serialization, honest capability/fallback and differential oracles, including ADR 0002. |
| M8 | Actual Linux external texture and Android surface pinch → Rust camera → wgpu/Vulkan → compositor. Long-lived device/queue/pipelines/cache, latest-state mailbox, no per-frame bytes through Dart. Resize, orientation, fences, context loss, background/resume and cleanup. Native copying is diagnostic, not zero-copy proof. Hardware timing is separate. |
| M9 | Mandelbulb 3D camera/raymarch/depth, edited-state output and lifecycle on both native targets. |
| M10 | Escape-time, roots, attractors, IFS, cellular, number systems, 3D, hypercomplex and custom-family ports. WGSL canonical only per qualified migrated family. Conversion is assistance, not analytic/image/provenance proof. |
| M11 | Rust render/backend/scheduler/cancellation/diagnostics ownership; Flutter viewport only presents/captures input. Retire legacy renderer only after every required module has a qualified replacement. |
| M12 | Pinned snapshot/revision for viewport and 4K/8K PNG export, bounded memory/tiles/cancel and dimension/crop/color/alpha/error/readback parity. Flutter transports/saves/shares only. |
| M13 | Versioned Rust preset semantics and legacy saved/history/import/deep-link round trips, exact primes and invalid ingress behavior. Storage transport remains Flutter. |
| M14A / M14B | Rust WASM core with legacy renderer, then WebGPU render/export/download. Actual browsers, capability/loss/fallback checks and no stranded Web path at final retirement. Native does not wait for Web. |
| Cross-cutting / final | Default-off RUST_CORE/CPU/GPU/EXPORT until each route qualifies, valid flag/module/backend combinations and rollback without state loss. Coarse FFI, ordered input application before render coalescing, export revision pinning, bounded threads and durable resources. Preserve full offline gate, add Rust/analytic/shader/differential checks, and qualify Linux/Android/Web separately. Audit imports/dependencies and real runtime routing: no Dart mathematical formulas, backend decisions, uniform math, fractal rendering or PNG engine. Flutter UI/l10n/accessibility/platform I/O remain. |

### Auxiliary mathematical domains retained

These are accepted final Rust scope, not new features or completed ports. The
M10/M11/final audit must include them, with independent deterministic oracles:

- Fourier transforms (`lib/features/fourier/services/fourier_transform_service.dart`),
  RGBA spectrum/features (`fourier_image_analyzer.dart` in the same directory),
  discrete Cantor masks and restricted Fourier/norm estimation
  (`lib/features/fourier/lab/`). Preserve unitary forward/inverse, alpha/window/DC
  choices, finite-operator claims and cancellation. Existing tests are under
  `test/features/fourier/`. Widget layout, capture and platform leases stay Flutter.
- RK4 trajectories (`lib/core/modules/attractor_trajectory.dart`), integration,
  settings, bounds and cancellation; oracles in
  `test/modules/attractor_trajectory_model_test.dart` and
  `test/fractal/attractor_trajectory_compatibility_test.dart`.
- Exact Number Walls sequences, grids and certification
  (`lib/core/models/number_wall_model.dart` and controller-owned asynchronous
  ingress); retain decimal replay and `test/number_walls/` plus model/parity tests.
- Gaussian prime maps/walk adjacency and bounded cancellable jobs
  (`lib/core/models/gaussian_moat_model.dart`), with model and viewer walk tests.
- Prime-norm quaternion slices/membership/adjacency
  (`lib/core/models/prime_norm_quaternion_model.dart`), with model and viewer walk
  tests. Separate its current `dart:ui` presentation dependency from domain logic.
- Other exact/special catalog visualizations and any existing mathematical
  audio/analysis algorithm found by the later dependency audit. Inventory real
  owners and tests before retirement; do not assume the module manifest enumerates
  every auxiliary service. Do not add an absent audio feature.

### Predeclared native measurement protocol

Carry this protocol into the M8 hardware qualification task before measurement.
No available hardware or benchmark result is claimed now. Record device/GPU,
physical display refresh, OS/driver/backend, source/build/flags, module/parameters,
viewport/DPR, zoom and deterministic input trace before the run. Waydroid is the
Android functional target, not the hardware timing source.

Planner defaults: Mandelbrot declared default plus a fixed recorded pan/pinch
trace, 1280×720 logical viewport at DPR 1, 5 seconds warmup and 30 seconds measured
steady state. Use monotonic input, Rust render completion and compositor-present
markers with revision IDs; do not substitute Flutter UI animation FPS. A missing
present/latency instrument is missing proof and must be built before qualification.
For the 60 Hz demonstration, predeclare p95 presented-frame interval <= 1000/60 ms,
no stall > 100 ms, and p95 input-to-present latency <= 50 ms. Report the full
frame-interval/latency distribution, dropped/stale revisions and maximum stalls.
The optional 120 Hz case requires compatible hardware/display and a separate
predeclared trace/run with p95 interval <= 1000/120 ms; never infer it from 60 Hz.
These are planner-selected future measurement criteria, not observed performance
or requirements for CPU precision refinement/export. Fix all scenario/statistic
changes before collecting qualification data, not after seeing favorable results.
Correctness, honest precision and texture/lifecycle gates remain independent.

## Verification and continuation

Premortem: decimal loss → exact string/numeric-type round trips and mutations;
false M1 pass → official terminal results plus source/target/cleanup bindings;
forgotten domain/Web path → complete proof map and auxiliary owner/test inventory.
All tasks preserve IDs, saved formats, mathematical qualifications and the working
Dart renderer. Proposed task commands are unrun in this planning pass.

Use the current self-contained `Full check:` in root `AGENTS.md`, not historical
3.44.6 snippets in runbook/test-plan/Waydroid prose. It selects the existing Git
common-directory Flutter 3.47.9/pub cache; verify `fdroid/flutter.version` and the
provisioned `/usr/bin/python3` imports. Rust uses the existing 1.95.0 binaries and
isolated locked Cargo cache. Do not install or mutate profiles during planning.
The runner retains its merged-tree and full-main checks; focused results are not
full-gate evidence. Keep actual errors/timeouts, never skipped success.

Builder check completed with a fresh read-only reviewer against the saved task
contracts, sources and native/catalog seams. Result: **nothing important left**.
The reviewer confirmed exact-number preservation, the necessary dependency-guard
repair, official Linux protocol results, bounded Waydroid consent and the complete
remaining-proof map. No implementation or native run was performed by this review.
Final parent readback also added the existing spec dependency-status owner to the
catalog task's Touches; it must not retain a local-only statement after serde is
added. This resolves documentation drift, not a product or authorization change.
No task demands a coordinator receipt, fabricated lease or new product approval.
Selection is not runtime admission. Shared test-fixture edits do not create producer dependencies;
Waydroid is a real shared mutable resource, and Cargo manifest/lock edits retain
protected-path admission. Three independently reviewable building outcomes are
expected, with normal runner review/integration per candidate, not a promised
runtime or performance gain.

Close RUST-PLAN-02 manually with this plan as evidence. Save exactly one open
successor, RUST-PLAN-03, Plan round: 2 of 10, depending on all three building tasks.
Its next frontier is M2 sole-owner state design/implementation after reconciling
M1 proof and typed catalog results, not a big-bang controller port. Preserve the
remaining map even if a native run fails. Runtime failures return to the same
coordinator with exact operation/evidence; do not duplicate candidates or reopen
settled product choices. The chain can continue under the same coordinator up to
round 10. Move the successor to Needs decision to stop it. A later round with no
new building task, or round 10, must save the required stop question/open remaining
proof task unless executed ledger evidence proves the goal met.
