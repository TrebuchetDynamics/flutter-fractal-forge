# RUST-M2-RANDOM-ORACLE — Exact seeded Dart randomization oracle

## Scope and status

Implemented locally for coordinator review and integration. The
[randomization oracle](../../migration/oracles/randomization.json) records
unchanged production Dart behavior. It does not implement a Rust RNG or change
randomization or undo policy. The
[accepted oracle plan](RUST-PLAN-07.md#seeded-randomization-oracle) and
[engine migration scope](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
remain unchanged.

## Capture and comparison

The [focused test](../../test/migration/randomization_oracle_test.dart) executes
all scenarios twice through the
[support helper](../../test/migration/support/randomization_oracle.dart).
Normal runs compare the complete document with the committed fixture and never
write it. The test also changes a source hash and a nested cell expectation,
then checks that the same comparator rejects both changes.

The fixture contains schema version 1, runtime versions, source bindings, ordered
parameter schemas, scenario inputs and full expected outputs. Object keys use
[the existing canonical JSON writer](../../test/migration/support/baseline_inventory.dart).
Array order remains significant. Parameter kinds distinguish integer, double,
boolean and text values. Exact Number Walls cells and moduli remain decimal
strings, not floating-point conversions.

Source bindings reuse the conservative
[replay source graph](../../test/migration/support/replay_codec.dart), including
its existing replay roots. They also hash this task's test/helper and the pinned
Dart SDK's `lib/math/random.dart` and VM `lib/_internal/vm/lib/math_patch.dart`.
No machine path or capture timestamp enters the fixture. The checked capture has
148 source bindings. An unrelated change in this conservative graph can require
review too. Do not remove a binding just to make a drift check pass.

### General randomization

Eighteen scenarios cover Mandelbrot, Julia and a synthetic module, each with
seeds `0`, `1`, `42`, `2147483647`, `-1` and `2147483648`. Each scenario loads
explicit parameters and calls `randomizeParams(animate: false, random: recorder)`.
The recorder delegates each `nextInt`, `nextDouble` or `nextBool` call exactly
once to `Random(seed)`. Its method, bound, value and order are actual injected
calls, not a reconstructed transcript of internal PRNG steps.

The synthetic module reuses an existing module's inert rendering fields. It
covers all five parameter types, fractional integer bounds, all four enum value
kinds, an empty enum, exact decimal text, palette preservation and near-boundary
Julia fields. `colorScheme` and `colorCycleSpeed` consume no draw. Integer bounds
are inclusive from `ceil(min)` to `floor(max)`. Julia fields use the production
radius `0.35`, clamp before step snapping, then pass through the shared
normalizer. Float step snapping uses production rounding and six-decimal cleanup.
The fixture retains schemas, draws and outputs so these decisions remain visible.

### Number Walls and undo

Fifteen scenarios start with prime `97`, four rows, sixteen columns and
`columnStart: 3`. Both modulus opt-in states cover the six required seeds.
Opt-in seeds `3`, `8` and `19` additionally reach primes `11`, `13` and `3`, so
all six quick-pick primes have actual controller captures. The required seeds
also show `-1` materializing as `2147483647` and `2147483648` as `0`.

`randomizeNumberWall` constructs its own Random. Therefore the explanatory draw
transcript is explicitly **separately derived**, not instrumentation. It follows
the pinned generator and source call order: source, color scheme, background,
foreground, zero color and optional modulus. Every derived field is checked
against the actual public controller result. Expected params, status and every
cell always come from that controller, not from the explanatory transcript.

Each successful scenario changes the current view and transparency, then undoes
once. Exact prior params/grid return, while the changed view/transparency stay.
A second undo returns false without changing state.

A separate ordered scenario records eighteen reached public actions and results.
It checks no undo before a commit, cancellation of pending randomization,
composite ingress rejection, revocation of a pending load's ownership and
navigation during another randomization. Futures are awaited explicitly. Pending
state guards prove that cancellation/navigation occurred before completion. There
are no test sleeps. Rejected or cancelled work retains the earlier committed undo.
Navigation clears undo under the existing production policy and cannot resurrect
the abandoned wall.

## Scratch export and review

Use the root [pinned offline setup](../../AGENTS.md#common-offline-integration-gate).
Set `FLUTTER_ROOT` and `PUB_CACHE` to the existing provisioned cache. Verify Flutter
against `fdroid/flutter.version`, check the prescribed Python imports, then run
`flutter pub get --offline --enforce-lockfile` without changing the lockfile.

For an explicit capture, choose a new, empty absolute directory under private
`TMPDIR`, outside the checkout:

```sh
flutter test --no-pub test/migration/randomization_oracle_test.dart \
  --dart-define=MIGRATION_RANDOMIZATION_OUT="$TMPDIR/randomization-a"
flutter test --no-pub test/migration/randomization_oracle_test.dart \
  --dart-define=MIGRATION_RANDOMIZATION_OUT="$TMPDIR/randomization-b"
diff -ru "$TMPDIR/randomization-a" "$TMPDIR/randomization-b"
```

Export mode checks repeated execution, finite JSON, semantic assertions and
mutation rejection. It deliberately bypasses the committed fixture comparison
so source drift can be reviewed. It writes only the scratch `randomization.json`.
It rejects relative paths, checkout paths (including resolved symlinks) and
nonempty directories. It never promotes output. Review source bindings, scenario
inputs, actual outputs and draw provenance before a separate explicit copy into
the designated fixture. Never refresh original `migration/baseline` files.

## Checks and limits

Setup verified Flutter 3.47.9/Dart 3.13.7 and the prescribed `/usr/bin/python3`
imports. Offline, lockfile-enforced package resolution passed.

| Check | Result |
|---|---|
| `flutter test --no-pub test/migration/randomization_oracle_test.dart` | Passed: one focused test, two full executions, exact immutable-fixture comparison and source/nested-mutation rejection. |
| `flutter test --no-pub test/number_walls/number_wall_randomizer_test.dart test/number_walls/number_wall_state_test.dart test/fractal/fractal_controller_behavior_test.dart` | Passed: all 14 existing tests. |
| Two scratch export commands above, their directory diff, and diff against the committed fixture | Passed: byte-identical documents. |
| Scratch source-binding inspection | Passed: all 148 hashes matched actual files, including the SDK sources. All six opt-in primes appeared in actual outputs. |
| `flutter analyze --no-pub test/migration/randomization_oracle_test.dart test/migration/support/randomization_oracle.dart` and focused `dart format --output=none --set-exit-if-changed` | Passed: no analyzer issues or formatting changes. |
| `git diff --exit-code -- lib migration/baseline rust packages pubspec.lock && git diff --check` | Passed: production owners, original baselines, Rust, packages and lockfile unchanged. |
| Scoped Docs Sync Maintain readback | Passed: this note's local links/anchors, scenario counts, API/field names and check claims match source, fixture and executed checks. Generic Docs Sync checks have no role manifest here and provide no content coverage. |

This change reuses the controller, parameter randomizer/normalizer, locked hashing
dependency, canonical JSON and replay binding conventions. No dependency, production
flag, PRNG implementation, M0 fixture or shared task/history file changes.
The only maintained component document is this note.

A later source-matched Rust RNG, Rust randomization and staged Session undo remain
unported by this task. Ordered interpolation and browser RNG proof remain separate.
These pinned Dart VM captures are not a cross-version RNG promise, browser parity,
a runtime ownership switch, native/hardware qualification or a performance result.
The runner owns the merged-tree full offline gate. It was not run by this worker.
