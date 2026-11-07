+++
schema = 1
id = "RUST-CORE-BOOTSTRAP"
title = "Adopt existing Rust candidate and reduce bootstrap to two pure-domain crates"
short = "Preserve the existing producer, defer fractal-render and add view/snapshot revision infrastructure."
status = "open"
goal = "RUST-ENGINE-001"
section = "Next"
rank = 4000
depends_on = ["RUST-M1-WORKSPACE"]
touches = ["rust/Cargo.toml", "rust/Cargo.lock", "rust/crates/fractal-core/Cargo.toml", "rust/crates/fractal-core/src/lib.rs", "rust/crates/fractal-core/src/view.rs", "rust/crates/fractal-core/src/snapshot.rs", "rust/crates/fractal-core/src/precision.rs", "rust/crates/fractal-render/Cargo.toml", "rust/crates/fractal-render/src/lib.rs", "rust/crates/fractal-bridge/Cargo.toml", "rust/crates/fractal-bridge/src/lib.rs", "scripts/ci/rust-check.sh", "docs/engineering/spec.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Consume the integrated RUST-M1-WORKSPACE result; retain its version/toolchain/checks and correct only the owner-rejected placeholder layout. Remove fractal-render and its workspace/bridge edges, update lock and source/dependency guard, add core view.rs/snapshot.rs/precision.rs (policy implementation deferred) and neutral ViewState plus session/revision snapshot model. Six f64 fields use existing Dart pan/rotation/zoom representation; engine snapshot is a probe, not active viewer state. Revision0 at creation, reads stable, internal committed mutation increments once and overflow errors. Pure core independent of bridge/UI/GPU even via dev/build/transitive edges. Do not rebuild the old candidate from scratch."
acceptance = ["Given the adopted workspace, cargo test --package fractal-core passes independently and its dependency guard excludes Flutter/Dart/FRB/Android/GPUI/wgpu edges while admitting ordinary pure-Rust dependencies; exactly core/bridge remain, engine_version is 0.1.0.", "Given neutral view and snapshot, inline Rust unit tests prove six finite fields, independent sessions, stable repeated reads, mutation revision increment and no u64 wrap; no application state, gestures, renderer, presets or saved data are changed."]
checks = ["( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; cargo fmt --manifest-path rust/Cargo.toml --all -- --check && cargo clippy --manifest-path rust/Cargo.toml --workspace --all-targets --locked --offline -- -D warnings && cargo test --manifest-path rust/Cargo.toml --workspace --locked --offline )", "( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; cargo test --manifest-path rust/Cargo.toml --package fractal-core --locked --offline && cargo tree --manifest-path rust/Cargo.toml --package fractal-core --edges normal,build,dev --target all --all-features --locked --offline )", "( export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\"; export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\"; export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\"; flutter --version && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No wgpu/WGSL/shader or registry migration, UI redesign, live camera commands, CPU renderer or Dart policy deletion.", "Preserve active RUST-M1-WORKSPACE candidate and contract; no worker interruption, evidence repinning, publication or changes to unrelated dirty tests."]
+++
- Sources: docs/planning/refactor-plan.md#rust-core-01-bootstrap-refinement
- Owner decision: exactly two bootstrap crates; render crate returns only with CPU work. Existing producer d18e1338 is at coordinator verification, not permission to rewrite its contract. If not landed, preserve/return to the same coordinator for supported source inclusion; do not fork a replacement implementation.
- Produces: core ViewState {center_x,center_y,zoom,rotation_x,rotation_y,rotation_z:f64}, EngineSnapshot {session_id,revision:u64,view}; stable engine_version 0.1.0. Internal state mutations only; no camera FFI.
- Repo obligations triggered: spec.md Planned Rust engine boundary and accepted refinement. Update dependency test currently hardcoding render in candidate core/lib.rs and bridge capability re-export; preserve old history. Explicit manifests/lock/deletions in touches; no generated outputs/CI changes beyond existing script. New inline domain tests proposed/unrun.
- Next action: add failing two-member/dependency and snapshot revision tests against the adopted candidate.