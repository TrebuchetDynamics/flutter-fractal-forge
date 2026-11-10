# RUST-M2-TRAJECTORY-BRIDGE — typed bounded trajectory transport

## Result and qualification boundary

The inert bridge now exposes typed trajectory ingress, detached metadata and
terminal frames, and Future request methods. The separate
[`rust_state_trajectory_smoke_test.dart`](../../integration_test/migration/rust_state_trajectory_smoke_test.dart)
was analyzed and compiled for Linux and Android x86_64. **Its native assertions
were not executed.** Neither Web build executes these assertions or loads Rust.
No install, device/browser run, app/controller/render switch, new runtime,
admission scheduler, performance claim or full M2 qualification is included.

This implements the [typed transport plan](RUST-PLAN-08.md#typed-trajectory-transport)
using the existing [core jobs/cache](RUST-M2-TRAJECTORY-JOBS.md) and
[normal FRB dispatch rules](RUST-M2-ASYNC-STEP.md). The
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [migration acceptance](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
remain unchanged.

## Public seam and reuse

- `StateTrajectorySettings::new` delegates finite seed, positive bounded step size
  and work/sample caps to core. Version 1 and integrator `rk4` are explicit typed
  ingress requirements. Enums carry the three approved systems and projections.
  Settings getters return the complete validated representation.
- Separate `StateTrajectoryCamera` and `StateCommand::view_trajectory`,
  `apply_preset_trajectory` and `load_trajectory` constructors preserve the existing
  `StateCamera` contract. A bare true presence marker still rejects atomically.
  Null settings remain legacy absence. Core compatibility filtering is retained:
  settings for a different module/system/projection become absence, not invented
  defaults and not a new bridge rejection policy.
- `StateSnapshot` exposes settings, settings generation, pending/status and the
  last good frame. `StateTrajectoryFrame` owns an Arc to the immutable core frame;
  getters return a detached complete point list (at most 20,000 xyz samples),
  projected bounds, settings, module ID, originating Session ID, settings generation
  and cache-hit provenance. Current snapshot metadata can differ from retained
  frame settings. Request tokens remain opaque; no private core counters are exposed.
- `begin_trajectory_async`, `advance_trajectory_async` and
  `cancel_trajectory_async` use normal FRB dispatch and the existing Session mutex,
  identity/revision checks and close behavior. Begin captures settings without
  integrating; advance calls exactly one existing core chunk (at most 256 steps).
  Revocation uses the existing Rust-local `RequestGuard`, wrapped with a typed
  trajectory name. No foreign callback, drain loop or additional executor exists.
- One process-local `OnceLock<TrajectoryCache>` supplies cloned cache-service
  handles to every bridge Session. Core still owns three-entry LRU behavior,
  complete-settings equality, successful-samples-only insertion and retained frames.
  Cache hits create fresh Session-local publication provenance on advance.

Generated-source readback confirms all three request wrappers use `wrap_normal`,
`FfiCallMode::Normal` and Dart `executeNormal`/`Future`. Session, request and guard
arguments use borrowed `Auto_Ref` codecs and `lockable_decode_sync_ref`; the normal
closures retain their decoded opaque references until the call returns. Settings,
cameras and commands use owned transport. Returned snapshots, progress, frames and
settings are independently owned handles. Identities/generations remain `BigInt`
with unsigned-64 codecs. The target disposes all returned handles and closes its
Sessions; whole point buffers cross once per getter, never per point.

## Source-bound input producer

`run_state_session_smoke.py --trajectory -- COMMAND ARGS...` selects only
`thomas_attractor`, `four_wing` and `lorenz_2d`, preserving each complete original
record. It rejects simultaneous `--extended`. Original SHA-256 checks, lexical
JSON numbers, source-set/projection provenance, override/inherited-define refusal
and Flutter's 32,768-byte encoded aggregate limit are unchanged. Existing default
and extended projections still match their unchanged target hashes.

| Input | Projected SHA-256 | Bytes |
| --- | --- | ---: |
| modules | `83198465bebb3c9a7b15f9149be088fa2dd4a12291f7fdf11d9a84b92ee0032d` | 1792 |
| parameters | `e632d446426f15fd91b7b2ba857223933bf4fab78f882f42a76af1e4af94c9bd` | 10608 |
| presets | `32a03b55f5b4407ab36a94209ab48a80812740316ca039d8dc558926356d108c` | 3208 |
| capabilities | `be4156405585d0f56ca806c1f08346ef2447ed9dbc2d29a97d2d180a2ae82b1f` | 6591 |

Both native build invocations reported **6952/32768 encoded bytes**, including
`RUST_CORE=true`. The Python public protocol tests cover all three modes,
missing/duplicate selected records, source tampering, mode conflict, argv/exit
preservation and inclusive aggregate limits without launching oversized commands.

## Source, generated and artifact identities

Baseline: `021bf2ded098971bffc2c539af2f1e215bce1968`. This retry reuses the
scoped implementation from `fa440a9f415ef14c1eb7a09b3b98cf1070f43891` and
repairs the held target's enum-name mismatch. FRB generates `lorenz2D`, while
the Dart model uses `lorenz2d`. The target now maps both system and projection
enums with exhaustive switches and compares enum values, not names. Thus all
three systems can reach the compiled numerical assertions. A future generated
enum rename fails analysis/compilation instead of a runtime `byName` lookup.
This is a source-level repair, **not executed native Lorenz coverage**.

Verification used the existing
isolated caches: Flutter 3.47.9 (framework `c197ca5199`, engine `89c39edfdf`),
Dart 3.13.7, Rust 1.95.0 (`59807616e1fa2540724bfbac14d7976d7e4a3860`, LLVM 22.1.2),
FRB runtime/codegen 2.11.1 and cargo-expand 1.0.127. Android used the existing
cached target-enabled Rust compiler and existing NDK 28.2.13676358. No toolchain,
manifest, lockfile, baseline or build-rule change was made. `/usr/bin/python3`
3.12.3 imported pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
Offline lockfile-enforced Pub resolution completed before Flutter checks.

| Source path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/api.rs` | `a390d6f0237d72b9e0fb4382ffc527165a4d841bf576b11be6b225916c1b700c` |
| `rust/crates/fractal-bridge/tests/state_trajectory.rs` | `20e899864776790f394ab8cd322eb9586921cf89c60f4d9cfaa09ecf0c046128` |
| `scripts/migration/run_state_session_smoke.py` | `03ad83f7b2ce2b01c64f2ca53a287a77481e44e5286364b09d9fa4f977350821` |
| `integration_test/migration/rust_state_trajectory_smoke_test.dart` | `6c23bab2856e3dbc0cece29a8f1d73640b2e9b0dd6fd34c2cd2aa3e86273202b` |

Two complete five-file generations and inventories agreed byte-for-byte:

| Generated path | SHA-256 (both runs) |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `81399dc2e321395ffaceb7936352bad844d882a4e06b5360a3fac8fe310b8206` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `5d023aea2743b5e014dc92e86f93cc9daaf9e99895a05e060fdb3778ff1abbeb` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `7ed8fb34a0d268cdedd76f844023061735de7b3446a6e261e418fbbd722238a6` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `c1c221787afbb46d959ad08366212435480aa874e80c3213184b1033079c238e` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `9924b18c92ca47102561ff4abd72d6b3d961675da1c564d1f4aa7611b0046e0d` |

These checkout-local artifacts were compiled/inspected, not installed:

| Artifact path | SHA-256 |
| --- | --- |
| `build/linux/x64/debug/bundle/lib/libfractal_bridge.so` | `eb0a8f19d4ac525125f5b2a8dc88c46bd6fa5c349435cbd0207650c54bf2de74` |
| `build/linux/x64/debug/bundle/data/flutter_assets/kernel_blob.bin` | `d6611cacc43909824186fe04bb6808a1fcd5d6540a89af5f25e7e208aa51cae8` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `dd446527964f258367c65d75a3b41062ac090ff8e15a9aa466b14bed063ebeb1` |

The APK entry `lib/x86_64/libfractal_bridge.so` hashes to
`b78d1dea24f65c43a7e71d728098ef7324292f84adcd4fa7c4423eec2036660f`.
Its `assets/flutter_assets/kernel_blob.bin` matches the Linux kernel hash above.

## Checks and remaining consumers

All commands used the pinned offline environment above. Long suites/builds ran
through `autowork-run` with bounded timeouts. The coordinator owns the merged-tree
full offline gate; it was not run by this worker.

| Check | Result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_trajectory --test state_session --test state_number_wall --locked --offline` | Pass: 11 tests. |
| `scripts/ci/rust-check.sh` | Pass: formatting, denied-warning clippy and 104 tests including the compile-fail doc test. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml` twice, complete inventories compared | Pass: all five outputs agree; normal/owned/borrowed codecs read back. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: 12 cases. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib integration_test/migration/rust_state_trajectory_smoke_test.dart` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: 3 tests. |
| `/usr/bin/python3 scripts/migration/run_state_session_smoke.py --trajectory -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_trajectory_smoke_test.dart` | Pass: compiled only. |
| `RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" /usr/bin/python3 scripts/migration/run_state_session_smoke.py --trajectory -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_trajectory_smoke_test.dart` | Pass: compiled only. Existing Java/Kotlin tooling warnings are not native execution. |
| `flutter build web --debug --no-pub --dart-define=RUST_CORE=false && flutter build web --debug --no-pub --dart-define=RUST_CORE=true` | Pass: root Web compilation, not browser/native qualification. |
| Preservation diff for app, baseline, core, locks, codegen config and all three existing native targets; `git diff --check` | Pass: protected source is unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain/readback, bundled `docs.py stale .` and `docs.py check .` | Pass: this note's source/input/generated/artifact hashes and local links checked. No roles manifest exists, so bundled manifest checks report no manifest. |

Docs Sync Maintain is scoped to this designated component result note. It reuses
existing plan/spec owners without rewriting shared history, Acceptance or task
records. The coordinator/docs maintainer owns shared closeout and changelog
integration. Repeat readback makes no documentation change.

The new target asserts typed ingress, all points and projected bounds against the
existing Dart RK4 model for each approved system, two pending chunks then terminal
publication, shared-cache reuse, inactive/revoked guards, cancel/supersede/stale/
foreign ownership, legacy-null/marker rejection, settings invalidation, close and
retained readback with explicit handle disposal. These are **compiled assertions,
not observed native results**. Next-batch installed consumers must run this exact
new target with the official Linux driver and standing designated Waydroid target,
record source/input/library/backend identities and terminal assertions, and clean
up owned handles/artifacts. Existing targets' native evidence does not qualify this
one. Hardware, responsiveness/fair admission and full M2 remain separate gates.
