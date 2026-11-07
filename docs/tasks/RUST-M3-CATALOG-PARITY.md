# RUST-M3-CATALOG-PARITY — Typed catalog baseline reader

## Scope and status

Implemented locally for coordinator review and integration. This prepares M3 data;
it does not complete M3 or switch the live registry. The
[accepted batch](RUST-PLAN-02.md#next-executable-batch) and
[engine boundary](../engineering/spec.md#planned-rust-engine-boundary) remain binding.
State, persistence, rendering, presets and registry routing remain Dart-owned.

## API and preservation

[`fractal_core::catalog_baseline`](../../rust/crates/fractal-core/src/catalog_baseline.rs)
exposes `CatalogBaseline::from_jsons(modules, parameters, presets, capabilities)`.
It takes four JSON strings and returns `Result<CatalogBaseline, CatalogError>`.
The immutable `modules()`, `parameters()`, `presets()` and `capabilities()` accessors
return typed schema-1 envelopes. Their `payload.records` arrays preserve source
order. Serialize an envelope with `serde_json::to_value` or `serde_json::to_string`
for complete semantic readback, including provenance.

- `ModuleId` and `CatalogId` are distinct types with `as_str()` accessors.
- `ParameterKind` distinguishes integer, float, enumeration, boolean and
  decimal-integer descriptors. `ParameterValue` distinguishes JSON numbers,
  booleans and text. Enumeration options can have numeric or textual values.
- Numeric fields use `serde_json::Number` with `arbitrary_precision`. Exact
  decimal-integer strings stay text, including values beyond binary64 or u64.
  Loading checks decimal syntax only; it does not test primality or normalize values.
- Registry/catalog ordering preserves numeric values and nulls. Preset ordering
  also distinguishes an absent field from an explicit null.
- Typed presets, views, capability samples, provenance and mathematical claims
  retain their original fields. Flattened metadata maps preserve unknown fields
  at each object boundary. Presentation literals stay presentation data.

Construction is atomic. Errors reject malformed JSON or typed data, wrong
schema/kind, empty or duplicate identities, missing module coverage and broken
module references. Parameter identities are scoped to their module. Preset IDs
are unique across modules and within each built-in list. A default may share a
built-in ID only with an identical definition, excluding role-specific `order`.
Required nullable fields cannot silently become missing fields. The reader also
rejects objects with Serde's reserved `$serde_json::private::Number` key, using
`raw_value` inspection before typed decoding. Such objects must not silently
become scalar numbers, including inside unknown metadata.

The locked pure-domain dependency graph is listed in the
[workspace specification](../engineering/spec.md#isolated-rust-workspace-foundation).
The core/render boundary guard still checks all features, targets, normal, build
and dev edges. Synthetic Flutter/Android/GPUI edges and an actual injected FRB dev
edge are rejected.

## Checks

Setup used Rust 1.95.0 on task-local `PATH`, existing `cargo-1.95.0` cache and private
`TMPDIR`. Flutter 3.47.9 matched `fdroid/flutter.version`. Existing system Python
3.12.3 imported pytest, Jinja2 and `markupsafe.soft_str`. Checkout-local Flutter
metadata was generated with `flutter pub get --offline --enforce-lockfile`;
`pubspec.lock` remained byte-identical.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test catalog_baseline --locked --offline` | Passed: three focused public-seam cases. Tests read the original four `migration/baseline` files, compare every complete envelope without fixed counts, reject invalid mutations and conflicting preset aliases, and cover exact numbers/text, nulls and unknown metadata. Raw-input cases cover reserved-number object rejection. |
| `autowork-run scripts/ci/rust-check.sh` | Passed: formatting, denied-warning clippy, seven workspace tests and doc-test targets. |
| `flutter test --no-pub test/migration test/catalog/catalog_id_integrity_test.dart` | Passed: 34 tests. |
| `cargo tree --manifest-path rust/Cargo.toml -p fractal-core --edges normal,build,dev --prefix none --target all --all-features --locked --offline` (also `-p fractal-render`) | Reviewed: only local domain/render and the listed serde graph; no platform/UI edge. Existing lock entries were not upgraded. |
| Isolated scratch injection of `flutter_rust_bridge = "=2.11.1"` into core dev-dependencies, then the boundary test | Passed negative check: actual guard assertion failed with exit 101 and `unexpected dependency in fractal-core`. After removal, the guard passed and scratch manifest/lock matched the candidate. No injection entered the task checkout. |
| `git diff --exit-code -- migration/baseline && git diff --check` | Passed: no baseline changes or whitespace errors. |
| Scoped Docs Sync Maintain readback | Passed: local links/anchors, API names and locked graph match source. Normative sections and unrelated runtime paths remain unchanged. |

The merged-tree full offline gate belongs to the coordinator. It was not run by
this worker. No device, production, GPU, browser or native capability qualification
is claimed by these checks.

## Reuse and remaining gaps

The implementation reuses the M0 envelopes, existing domain crate, cached Serde
packages and existing dependency guard. It adds no copied fixtures, JSON parser,
bridge API, generated glue, baseline output or runtime owner. The scoped Docs Sync
Maintain pass updates this API/check note and only the specification's current
workspace dependency/status sentences. Shared task/history files remain unchanged.

Capability flags and mathematical claims are baseline statements, not Rust support
or mathematical certification. Debug/diagnostic inventory does not establish
release filtering. Custom shader setter ABI and sampled precision limitations
remain unresolved. Runtime parameter/session ownership, normalization, precision,
preset migration and the remaining M2/M3 gates stay with later tasks.
