# RUST-M2-GRID — Exact resumable Number Walls grids

## Result and scope

The pure core [number_wall_grid API](../../rust/crates/fractal-core/src/number_wall_grid.rs)
ports the six sequence families, Fibonacci doubling, signed residues, pivoted
modular determinants, extended-Euclidean inverse and cross-or-direct fallback.
It follows [the Dart model](../../lib/core/models/number_wall_model.dart) and
[the bounded-work design](RUST-PLAN-05.md#arithmetic-and-bounded-work).
No Session, bridge, renderer or app route uses this API yet.

`num-bigint = "=0.4.6"` supplies signed exact arithmetic internally.
Public arithmetic operands and results use decimal strings, without floating point
or machine-integer narrowing. Input permits ASCII digits with an optional minus
sign. Leading zeros are accepted. Results and grid modulus text are canonical.
Indices use `i64`; dimensions use `usize`. Unsupported negative sequence indices
and signed-Pagoda neighbor overflow return typed errors.

## API and publication

- `NumberWallSequence::{value_at,residue_at}` expose all six exact sequences.
  Fibonacci residues use modular doubling without constructing the full integer.
- `determinant_matrix_mod`, `determinant` and `cross_or_determinant` expose the
  source mathematics. Cross operands are `[northWest, west, east, denominator]`.
  A zero denominator falls back to the direct determinant. A nonunit returns
  `NumberWallError::NonInvertible`. Empty matrices return `"1"`.
- `NumberWallDeterminantJob::new(matrix, modulus)` parses an owned square matrix.
  Construction parses decimal input; normalization and elimination occur in steps.
- `NumberWallGridJob::new(sequence, modulus, rows, column_start, columns)` validates
  rows 1..64, columns 1..256 and column_start in rows−1..1000000.
  `NumberWallGrid::required_support` returns inclusive support bounds with the
  source signed-Pagoda extra halo. Sequence residues are cached once per job.
- Both jobs expose `advance(&AtomicBool, work_limit)`, `phase()`,
  `last_work_units()` and `result()`. `None` means pending. A terminal `Result`
  contains the complete value or a typed error, including `Cancelled`.
  Terminal results remain stable after later calls or cancellation.
- `NumberWallGrid::generate` and the synchronous determinant helpers drive the
  same elimination cursor. Grid generation uses direct determinants, as Dart does.
  Completed grids expose only shared getters, including immutable cell strings.

Each advance performs at most `min(work_limit, 1024)` scalar work units.
One unit covers one support residue, matrix entry initialization/normalization,
pivot probe (including a row swap and product update), inverse, elimination row
probe/factor, scalar matrix update or completed cell. These operations have explicit
cursors; an entire determinant or grid is never charged as one unit.
Bigint arithmetic, inverse and decimal conversion are indivisible operations.
This bound is not an 8 ms or other wall-clock responsiveness guarantee.

Grid jobs return pending at every completed row. The last row checkpoint leads to
a separate final checkpoint before publication. Cancellation is checked per unit,
at row boundaries and again before final publication. No partial grid is exposed.
Callers can use a smaller work limit to interleave support or elimination work.
Standalone determinant jobs also check cancellation before publishing their result.

## Setup and verification

Dependency resolution used Rust 1.95.0 from the existing pinned toolchain and
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`. The one-time
`cargo check --manifest-path rust/Cargo.toml -p fractal-core` and
`cargo fetch --manifest-path rust/Cargo.toml --locked` succeeded. The lock diff adds only
num-bigint 0.4.6, num-integer 0.1.47, num-traits 0.2.19 and autocfg 1.5.1.
Unrelated locked package versions remain unchanged. No arithmetic rand/serde
features were requested. Subsequent Cargo checks used `--locked --offline`.

Flutter 3.47.9 matched `fdroid/flutter.version`; Dart was 3.13.7.
The provisioned `/usr/bin/python3` imported pytest 9.0.2, jinja2 3.1.6 and callable
`markupsafe.soft_str`. Checkout-local package metadata was regenerated with
`flutter pub get --offline --enforce-lockfile` and the existing isolated PUB_CACHE.
No host profile, ambient cache or SDK installation was used.

Checks passed:

- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test number_wall_grid --locked --offline`:
  five public-seam tests. The unchanged independent Bareiss identities produce
  **971 cases**, fingerprint **196b53dc**. Additional cases cover large signed
  entries and results above u64, Fibonacci doubling, malformed operands, empty and
  non-square matrices, nonunits, complete/stepped agreement for all six families,
  a stepped 64×1 grid, a 1×256 grid at origin 1000000, support bounds, work caps,
  pivot cursors, stable terminal results and cancellation at support/elimination/
  row/final checkpoints.
- `autowork-run scripts/ci/rust-check.sh`: formatting, denied-warning clippy and
  all 35 workspace tests passed. The strict core/render package-set guard retains
  normal/build/dev, all-target/all-feature coverage and injected Flutter/Android/
  GPUI rejection checks. Only the resolved pure arithmetic closure was added.
- `flutter test --no-pub test/modules/number_wall_model_test.dart`: eight source
  model tests passed. The Dart model and parity fixtures remain unchanged.

The scoped Docs Sync Maintain pass updates this result note and only the current
foundation dependency description in [the spec](../engineering/spec.md#isolated-rust-workspace-foundation).
The Number Walls replay validation boundary, migration baselines, generated files
and saved formats remain unchanged. The runner owns merged-tree full checking;
this worker did not run the full offline gate.

## Limits and next consumer

A modulus >=2 is an arithmetic operand, **not a prime certificate**.
Composite moduli can fail on a noninvertible pivot. The existing prime validator,
proof budget and replay validation boundary are unchanged.

RUST-M2-FRAME must compose prime certification with this grid job and own immutable
certified-frame reuse. Session request ownership/ingress, executor and bridge
transport, native/browser execution and app routing remain separate work.
These offline arithmetic results do not qualify hardware timing or live rendering.
The implementation reuses the source direct-determinant algorithm and one cursor
for synchronous/stepped elimination. It omits cross-rule grid optimization, a new
bignum implementation, async dependencies and routing changes.
