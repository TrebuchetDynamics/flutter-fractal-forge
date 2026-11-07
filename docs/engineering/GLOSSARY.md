# Mathematical engine migration terms

These terms govern the
[Flutter-shell/Rust-engine migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
They describe accepted future ownership, not implementation status.

## Rust mathematical engine

The future Rust-owned mathematical domain layer: catalog semantics, parameter and
preset meaning, camera transforms, precision, fractal rendering/export and auxiliary
domain algorithms such as Fourier transforms, trajectories and exact discrete
visualizations. Flutter owns UI/accessibility, presentation calculations and
platform I/O.

Avoid using “Rust bridge installed” or “Rust GPU enabled” as synonyms for “100% Rust
core.” Those are intermediate states. See
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md).

## Native architecture demonstration

The source-bound end-to-end demonstration that physical input reaches Rust camera
and fractal rendering, then wgpu and Flutter native composition, without routing
each frame's pixels through Dart. Its initial performance target is 60 Hz on a
declared hardware/scenario pair; 120 Hz is an additional compatible-hardware target.
Waydroid functional evidence and hardware performance evidence remain distinct.

Avoid “all fractals run at 60/120 FPS,” “Waydroid proves physical GPU performance”
and “UI FPS proves renderer throughput.” See
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md).
