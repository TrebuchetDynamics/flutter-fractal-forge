# RUST-M2-MORPH-TIMELINE — Explicit module morph ticks

## Boundary and source

Implemented in the inert Rust `session::Session` only. The controller and bridge
remain unchanged. The accepted scope is the [morph timeline plan](RUST-PLAN-09.md#morph-timeline),
under the [migration boundary](../engineering/spec.md#planned-rust-engine-boundary)
and ADRs [0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[0006](../adr/0006-native-demonstration-performance-is-target-specific.md).

Source: `lib/core/controllers/fractal_controller.dart`, `selectModule`,
`_startMorphTransition` and `_commitLoadedState`. This is source-derived core
numerical evidence, **not differential proof of a non-skipped Dart morph**.
The controller's `_isTest` branch skips morph timers in automated tests.

## Owned behavior

- `apply_batch` uses the source defaults: ordinary different-module selection
  starts/replaces a morph; `Load` does not. Previous ID is the module immediately
  before that selection, not an earlier morph's previous ID.
- `apply_batch_with_module_animation` supplies the explicit source `animate` or
  `animateModule` option for selection/load commands in that batch. It has no
  effect on other commands. Animated different-module loads start a morph before
  publishing their loaded parameters/view. Same-module loads do not start one.
- Same-module selection (including resetView), nonanimated selection/load,
  parameter/view/session resets and ordinary parameter operations do not cancel
  the source morph timer. Number Wall selection/load starts no morph. Successful
  deferred wall publication preserves current concurrent morph metadata rather
  than restoring its staged snapshot's old progress.
- Detached snapshots expose `is_morphing`, `morph_progress`,
  `previous_module_id` and the optional `morph_timeline_token`. Generation is
  checked and independent of parameter interpolation. A replacement gets a new
  token even within the same atomic batch.
- `tick_morph_timeline` consumes one logical callback. Steps 1–36 use
  `1 - (1 - step/36)^3`; step 36 publishes progress=1, false and previous=null.
  Completed/replaced/cancelled tokens are inert. Foreign identity or stale
  expected revision rejects before mutation.
- `cancel_morph_timeline` explicitly settles the matching generation to terminal
  metadata. This is a core lifecycle seam, not an invented blanket load/reset
  cancellation rule. It is idempotent and cannot cancel a replacement.
- Candidate publication, owner checks and terminal revision reservations reuse
  existing Session machinery. Failed mixed batches or revision exhaustion do not
  consume a callback or cancel/replace parameter ownership. Ordinary seeded
  targets and parameter ticks leave morph ownership independent.

## Verification

Pinned setup: Flutter 3.47.9 (matches `fdroid/flutter.version`), Dart 3.13.7,
Rust 1.95.0, existing isolated caches under the absolute Git common directory.
`/usr/bin/python3` successfully imported pytest 9.0.2, jinja2 3.1.6 and
`markupsafe.soft_str`. No dependency, lock, generated or source-fixture changes.

| Check | Observed result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_morph_timeline --test session_param_timeline --test session_randomization --test session_replay --locked --offline` | Pass: 13 tests. Three new public-seam cases cover all 36 ticks, source call-site behavior, replacements/cancellation, deferred wall publication and independent parameter/seeded state with mixed-batch rollback. Original replay still matches all 68 outputs. |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core revision_exhaustion_rejects_at_the_transaction_seam --lib --locked --offline` | Pass: existing exhaustion test extended to concurrent morph and parameter ownership, rejected tick/cancel/replacement and unchanged snapshots/hidden parameter step. |
| `scripts/ci/rust-check.sh` | Pass: workspace fmt, clippy with warnings denied, workspace tests including existing successful-only undo and terminal reservation cases. |
| `flutter pub get --offline --enforce-lockfile` | Pass: existing pinned package cache; lock unchanged. |
| `flutter test --no-pub test/migration/param_interpolation_oracle_test.dart test/fractal/fractal_controller_behavior_test.dart` | Pass: seven unchanged tests. Interpolation oracle remains interpolation evidence only. |
| `git diff --exit-code -- lib migration packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Pass: protected source/oracle/transport/lock paths unchanged; whitespace clean. |

## Reuse and remaining qualification

Reused Session snapshots, atomic candidates, identity/revision checks, terminal
reservations, seeded targets and parameter interpolation. The only adjacent owner
change is deferred wall publication's preservation of current morph metadata.
No clock, scheduler, new dependency, module admission, app animation switch,
production test override or captured Dart oracle was added.

Haptics remain Flutter presentation. The source schedules 36 callbacks at integer
16-ms intervals; this is not a measured 600-ms duration. Unsupported selection
branches (including Burning Ship aliases), non-skipped Dart morph differential
proof, native/app morph presentation and hardware/performance qualification
remain pending. Offline tests do not qualify those paths or enable app routing.
The full merged-tree check belongs to the runner gate, not this worker receipt.
