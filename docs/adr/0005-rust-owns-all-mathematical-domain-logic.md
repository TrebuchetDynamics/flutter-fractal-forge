# Rust owns all mathematical domain logic, not only fractal shaders

Accepted: the owner accepted Q1 of the Rust migration Grill With Docs round through
LGTM. The final Rust engine owns all application mathematical domain logic,
including Fourier transforms/analysis, attractor trajectories, exact Number Walls,
Gaussian/quaternion models and other special mathematical visualizations. Flutter
remains the presentation and platform shell. This extends the explicit final
inventory, not the first five building tasks.

## Context

The [migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
already covers catalog/state/precision/render/export ownership. Existing domain
algorithms also live in `lib/features/fourier/services/fourier_transform_service.dart`,
`lib/features/fourier/lab/`, `lib/core/modules/attractor_trajectory.dart`,
`lib/core/models/number_wall_model.dart`, `gaussian_moat_model.dart` and
`prime_norm_quaternion_model.dart` in that same models directory. A shader-only
port would leave a second mathematical engine in Dart.

## Considered Options

- Port fractal formulas/rendering only; retain other domain algorithms in Dart.
- Move all mathematical domain algorithms to Rust through the existing strangler
  migration, keeping Flutter presentation and platform integration.

## Consequences

Choose the second option to make the final ownership boundary consistent.
Dart can still calculate widget layout, format values, capture physical input and
perform platform I/O; these are not mathematical domain algorithms. Domain
coordinate transforms and camera semantics belong to Rust. Any mathematical
audio/analysis path found in the later inventory follows this boundary; this
decision does not add an absent feature.

Keep compatibility, exact integer semantics, provenance, cancellation and
differential checks for each existing domain. The next planning round must account
for auxiliary domains explicitly before final Dart retirement. Neither this
decision nor completion of the initial bridge establishes that they are ported.

[ADR 0002](0002-start-with-pure-dart-fixed-point-reference-orbits.md) remains valid
for its initial pure-Dart reference-orbit prototype. It becomes a differential
oracle during migration, not the final owner. This decision does not reverse the
prototype's dependency choice or select a Rust big-number library.
[ADR 0004](0004-control-surfaces-get-controls-from-declarations.md) keeps controls
declarative; moving descriptor semantics does not move widgets into the engine.

Term: [Rust mathematical engine](../engineering/GLOSSARY.md#rust-mathematical-engine).
