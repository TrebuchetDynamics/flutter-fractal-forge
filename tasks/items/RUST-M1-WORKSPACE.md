+++
schema = 1
id = "RUST-M1-WORKSPACE"
title = "Add isolated three-crate Rust workspace and nonpublishing CI checks"
short = "Create domain render and bridge boundaries with no Flutter behavior change."
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 4000
depends_on = []
touches = ["rust/Cargo.toml", "rust/Cargo.lock", "rust/rust-toolchain.toml", "rust/crates/fractal-core/Cargo.toml", "rust/crates/fractal-core/src/lib.rs", "rust/crates/fractal-render/Cargo.toml", "rust/crates/fractal-render/src/lib.rs", "rust/crates/fractal-bridge/Cargo.toml", "rust/crates/fractal-bridge/src/lib.rs", "scripts/ci/rust-check.sh", ".github/workflows/rust.yml", "docs/engineering/spec.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Create rust workspace with fractal-core, fractal-render and fractal-bridge; render depends on core, bridge on core/render. Use existing Rust 1.95.0 via task-local PATH, rust-toolchain.toml and Cargo.lock. Initial functions are engine version and an empty honest capability descriptor, not fractal ports or fake rendering. Add a path-scoped GitHub Rust check workflow and scripts/ci/rust-check.sh using fmt/clippy/test locked/offline after dependency provisioning. Core/render may not import Flutter/Android/GPUI; no new service/deployment/GitLab route. Keep bridge framework-free until next task."
acceptance = ["Given the new workspace, cargo tests exercise engine_version and capability serialization shape plus a dependency-boundary check; core/render contain no UI/platform dependencies and the app loads no Rust.", "Given the CI script/workflow, fmt, clippy with denied warnings and workspace tests execute with the pinned Rust and locked dependency graph; GitLab/publication/signing/Flutter lanes are not altered."]
checks = ["PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH cargo fmt --manifest-path rust/Cargo.toml --all -- --check", "PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH cargo clippy --manifest-path rust/Cargo.toml --workspace --all-targets --locked --offline -- -D warnings", "PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH cargo test --manifest-path rust/Cargo.toml --workspace --locked --offline", "( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; bash -n scripts/ci/rust-check.sh && scripts/ci/rust-check.sh )", "( export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\"; export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\"; export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\"; flutter --version && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No state/render replacement, ID renames, saved-data schema changes, publication or live device mutation in this offline task.", "Do not edit the seven pre-existing dirty test files; use isolated execution and preserve their work."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Planner call: no third-party dependencies required for this foundation; matched bridge/codegen dependency provisioning belongs to RUST-M1-BRIDGE. Existing direct Rust1.95.0 binaries were verified with --version; no installation or build ran. Workflow may acquire pinned toolchain in its disposable CI job, never mutate the owner's host.
- Produces: cargo workspace packages fractal-core/fractal-render/fractal-bridge; engine_version() -> String and capability descriptor with no rendering support advertised.
- Repo obligations triggered: spec.md Planned Rust engine boundary; explicit new protected manifests/lock/toolchain/workflow paths listed in touches. The dependency test belongs inline in crate tests, no artificial prose test. Update spec only to actual foundation status; no claim M1 platform qualification.
- Next action: implement the missing crate API/negative dependency-boundary tests, then the minimal workspace. All checks proposed/unrun.