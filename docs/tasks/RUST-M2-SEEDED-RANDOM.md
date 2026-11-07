# RUST-M2-SEEDED-RANDOM — Seeded draws and pure randomization targets

## Scope and status

Implemented locally for coordinator review and integration. These pure helpers
are inert M2 preparation, not a Session owner or an app routing change. The
[accepted seed/target contract](RUST-PLAN-08.md#seeded-rng-and-pure-randomization),
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) remain unchanged.

## Public API and source

Both modules are exported from
[`fractal_core::lib`](../../rust/crates/fractal-core/src/lib.rs).
They reuse the existing `Parameter`, `ParameterValue` and
[`normalize_parameter`](RUST-M2-NORMALIZATION.md#public-api) contract.
No dependency, entropy service, generated bridge or fixture refresh is added.

[`seeded_random::SeededRandom`](../../rust/crates/fractal-core/src/seeded_random.rs)
ports the Dart VM **3.13.7**, Flutter **3.47.9** implementation from
`dart-sdk/lib/_internal/vm/lib/math_patch.dart`. Its source hash is
`3cd16c96c4c1b6985317c6d3f9fab3e4b0466b87a9450230784249070d687790`
in the unchanged [randomization oracle](../../migration/oracles/randomization.json).
This is not browser or cross-version RNG equivalence.

- `SeededRandom::new(seed: i64)` mixes a signed seed as a wrapping 64-bit word,
  using logical right shifts and the Thomas Wang mixer. It performs four MWC
  warm-ups with multiplier `0xffffda61` and base `2^32`.
- `next_int(max: i64) -> Result<i64, InvalidBound>` accepts `1..=2^32`.
  Invalid bounds return before consuming state. Bound 1 still consumes a draw.
  Power-of-two masking and the source's strict `> 2^32` rejection rule remain exact.
- `next_double() -> f64` combines 26-bit and 27-bit draws into 53 bits.
  `next_bool() -> bool` is `next_int(2) == 0`. Cloning copies generator state.

[`param_randomization`](../../rust/crates/fractal-core/src/param_randomization.rs)
ports the unchanged [Dart value helper](../../lib/core/controllers/params/fractal_param_randomizer.dart)
and the general/Number Walls target construction in
[`FractalController`](../../lib/core/controllers/fractal_controller.dart).
The oracle binds both owners and the shared Dart normalizer by source hash.
Both target APIs return `Result<BTreeMap<String, ParameterValue>, RandomizationError>`:

- `general_targets(schema: &[Parameter], current: &BTreeMap<String, ParameterValue>,
  random: &mut SeededRandom)` follows slice order, not map keys or `order` metadata.
  It emits only schema fields. `colorScheme` and `colorCycleSpeed` retain their
  current value, or schema default if absent, without normalization or a draw.
  Floats use uniform range draws, except Julia real/imaginary seeds use radius
  `0.35` around their numeric default (or the bounds midpoint). Step snapping
  precedes shared normalization, with six-decimal cleanup and Dart's decimal
  half-away ties. Integers use inclusive `ceil(min)..=floor(max)` bounds.
  Enums retain the chosen option's integer/double/text/bool kind. Empty enums and
  decimal integers retain defaults without draws. Booleans use `next_bool`.
- `number_wall_targets(schema: &[Parameter], current: &BTreeMap<String, ParameterValue>,
  seed: i64)` uses `seed & 0x7fffffff` for both `randomSeed` and generator creation.
  It draws source, palette, background, foreground and zero color in that order.
  Zero color uses `0x808080 | draw`. A true `randomizeModulus` adds one draw from
  `2, 3, 5, 7, 11, 13`; otherwise the current custom prime remains unchanged.
  The resulting schema values pass through shared normalization, as Dart's
  `loadState` does. This helper does not certify a prime or build a grid.

Integer schema interiors outside signed-64 bounds, or with more than `2^32`
choices, return `UnsupportedIntegerBounds` before that parameter draws.
Unusable integer interiors use the shared default policy without drawing.
Missing/empty wall source options return `MissingWallSources`. A general-target
error can follow earlier parameters' draws; it does not roll the generator back.
Schemas are the typed numeric catalog contract, not an arbitrary nonfinite schema
input API. Synthetic schemas remain test inputs only, never Session modules.

## Checks and results

Setup used existing Rust **1.95.0** with
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`, private `TMPDIR`, and the existing
pinned Flutter/Pub cache. `flutter --version` reported Flutter 3.47.9, matching
`fdroid/flutter.version`, and Dart 3.13.7. `/usr/bin/python3` 3.12.3 imported
pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` passed without changing the lock.

| Command | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test param_randomization --test normalization --locked --offline` with pinned Rust/cache | Passed: six randomization and five unchanged normalization tests. |
| `autowork-run scripts/ci/rust-check.sh` with pinned Rust/cache | Passed: format, denied-warning clippy, workspace tests and doc-tests, including the unchanged dependency guard. |
| `autowork-run flutter test --no-pub test/migration/randomization_oracle_test.dart test/number_walls/number_wall_randomizer_test.dart` with pinned Flutter/cache | Passed: both unchanged Dart tests, including source bindings, exact oracle reconstruction, immutability, and existing wall replay/undo checks. This is not Rust Session proof. |
| `git diff --exit-code -- lib migration rust/Cargo.lock pubspec.lock packages && git diff --check` | Passed: Dart owners, original fixtures, locks and packages remain unchanged. |
| Scoped Docs Sync Maintain readback | Passed: this note's local links/anchors, API names, source/version/hash and check claims match the inspected source and results. A repeated readback leaves the note byte-identical. Generic Docs Sync check/stale commands report no role manifest and provide no additional coverage. |

The [public Rust tests](../../rust/crates/fractal-core/tests/param_randomization.rs)
compare every draw and target in all **18 general** and **15 wall** oracle cases.
Comparisons are exact, including double draws and parameter kinds. A continuation
draw checks general-helper consumption against each oracle transcript. All six
base seeds and opt-in seeds 3, 8 and 19 are consumed. Supplemental direct pinned-VM
vectors cover signed-64 seed extremes, bounds 1/`2^32`, and large-bound rejection.
Additional public target cases cover decimal ties, normalization after step
cleanup, and unsupported integer bounds without a draw.
The merged-tree full offline gate belongs to the runner and was not run here.

## Reuse and remaining proof

This change reuses typed catalog values, shared normalization, original oracle
schemas/expectations and the existing locked pure-domain dependency graph.
The scoped Docs Sync Maintain pass changes only this designated component note.
Shared policy, task records and release history are left to their existing owners.

RUST-M2-RANDOM-STATE remains the next consumer: Session admission, staged wall
commit/cancellation, undo provenance and timeline interactions are not implemented
or qualified here. Future animation can use an explicit generator but gains no
scheduler from this API. Browser RNG equivalence, bridge/native application routing,
installed-device/hardware behavior and full-M2 acceptance remain unqualified.
No production controller or renderer ownership changes are authorized by these results.
