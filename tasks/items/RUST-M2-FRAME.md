+++
schema = 1
id = "RUST-M2-FRAME"
title = "Compose exact prime and grid jobs into certified immutable Number Walls frames"
short = "Prepare certified frame transactions"
status = "done"
goal = "RUST-ENGINE-001"
section = "Next"
rank = 11000
depends_on = ["RUST-M2-GRID", "RUST-001-0fdde2b6"]
touches = ["rust/crates/fractal-core/src/lib.rs", "rust/crates/fractal-core/src/number_wall_frame.rs", "rust/crates/fractal-core/tests/number_wall_frame.rs", "docs/tasks/RUST-M2-FRAME.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Port NumberWallFrame.prepare as a pure resumable core job composing existing exact prime and produced grid jobs. Consume raw prime text, normalized non-prime params, optional prior module-owned immutable frame and explicit trial budget. Preserve previous proof only for raw text equal to prior canonical prime, Continue certification beyond default budget, matching-grid storage reuse and atomic immutable params/grid result. No public replay-flag/untrusted certificate constructor, prime algorithm change or Session enablement."
acceptance = ["Given proposed number_wall_frame tests against unchanged NumberWallFrame.prepare, invalid/composite/unverified/cancelled candidates carry no frame. Successful proof and complete grid canonicalize leading zeros and publish matching immutable settings/grid together. Forged primeVerified/status flags and generic decimal syntax cannot construct certificates.", "Given an actual larger-budget completed frame, exactly matching canonical raw prime text reuses its certificate under a lower budget; noncanonical leading zeros force revalidation. Identical sequence/prime/rows/columns/origin reuse immutable grid storage for style-only changes; mathematical-key changes recompute. Invalid start/dimensions or cancellation before/between/after stages leave previous frames untouched.", "Given complete/stepped tests, terminal status/frame/text are deterministic with bounded stages and final ownership-independent cancellation check. No partial frame escapes. Designated result note records reachable producer/consumer API, actual results and unported Session/platform executor/native/app proof."]
checks = ["PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\" cargo test --manifest-path rust/Cargo.toml -p fractal-core --test number_wall_frame --test number_wall_grid --test number_wall_prime --locked --offline", "( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; export CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\"; scripts/ci/rust-check.sh )", "flutter test --no-pub test/modules/number_wall_model_test.dart test/number_walls/number_wall_state_test.dart", "git diff --exit-code -- migration/baseline lib packages/fractal_engine_bridge rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check; read back certification/grid reuse against Dart source/public tests.", "( AUTOWORK_CACHE=\"${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}\" && export AUTOWORK_CACHE && export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\" && export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\" && test -x \"$FLUTTER_ROOT/bin/flutter\" && test -d \"$PUB_CACHE\" && export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No dependency/lock or prime algorithm/budget relaxation, Session/bridge/app/renderer route, untrusted certificate constructor, platform executor, randomizer/undo, baseline refresh or live qualification."]
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/RUST-M2-FRAME.toml"
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration; docs/tasks/RUST-PLAN-05.md#frame-and-session-ownership
- Consumes: RUST-M2-GRID exact resumable grid and RUST-001-0fdde2b6 private-result prime job. Produces: certified frame-preparation job/status and immutable frame for RUST-M2-INGRESS.
- Planner call: prime then grid stages; only actually completed owned frames allow proof reuse, never restored flags. Public/internal naming is reversible within this contract.
- Repo obligations triggered: docs/engineering/spec.md#number-walls-replay-validation-boundary unchanged; designated API/result/gap note, no generated output, saved-format/dependency change.
- Check setup: root AGENTS.md pinned Flutter 3.47.9/Dart 3.13.7, existing isolated SDK/PUB_CACHE/CARGO_HOME, Rust 1.95.0 and private TMPDIR. Compare Flutter to fdroid/flutter.version and verify provisioned /usr/bin/python3 pytest/jinja2/markupsafe.soft_str imports. RUST-M2-GRID supplies the new locked dependency/cache. Missing inputs/failures/timeouts remain failures; runner merged-tree Full check differs from focused worker checks.
- Next action: add failing proof-forgery, previous-proof/grid reuse and stepped cancellation tests before composition. Repair attributable blockers inside Touches without weaker expectations. All checks proposed/unrun in planning.
- Pending live: Platform executor/FFI, native/browser/app execution and hardware timing remain separate migration proof; this pure-core change adds no runtime route.
