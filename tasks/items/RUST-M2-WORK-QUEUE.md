+++
schema = 1
id = "RUST-M2-WORK-QUEUE"
title = "Bound admitted jobs and fairly select wall/trajectory chunks without a runtime"
short = "Bound and fairly select work"
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 3000
depends_on = ["RUST-M2-TRAJECTORY-JOBS", "RUST-M2-INGRESS"]
touches = ["rust/crates/fractal-core/src/lib.rs", "rust/crates/fractal-core/src/work_queue.rs", "rust/crates/fractal-core/tests/work_queue.rs", "docs/tasks/RUST-M2-WORK-QUEUE.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Implement pure bounded permit/round-robin policy keyed by Session identity/request kind/generation, composed in tests with real wall/trajectory jobs. Default 8 total active+queued jobs, one wall and one trajectory per Session; explicit Busy and atomic matching replacement, no hidden waiters/deduplication. Fair selection rotates Sessions and kinds one bounded chunk at a time. The bridge consumer, not this pure policy, submits to the existing FRB pool."
acceptance = ["Given work_queue tests with capacity+1 and replacement, no more than 8 total permits exist including stepped jobs; full admission returns Busy without state mutation/hidden retry list. Kind/identity/generation and checked ticket allocation reject foreign/stale/double release; completion/error/revoke/close/drop/panic-unwind simulations reclaim capacity exactly once.", "Given deterministic composed tests with real Session wall and trajectory requests, S runnable Sessions each receive a turn within S selections, alternating their runnable kinds; one turn performs at most existing bounded wall work or <=256 RK4 steps. Supersession/stale/overflow/divergence/cancel preserve last-good/retained frames and wall/trajectory isolation; no mathematical drain in queue operations.", "Given workspace and unchanged Dart trajectory/wall checks, no new runtime/dependency/thread/cache policy or fixture change occurs. Note records proposed internal capacity, policy API and exact pure-versus-executor limits for WORK-BRIDGE; no latency/throughput/native admission claim."]
checks = ["cargo test --manifest-path rust/Cargo.toml -p fractal-core --test work_queue --test session_trajectory_jobs --test session_number_wall --test session_replay --locked --offline", "scripts/ci/rust-check.sh", "flutter test --no-pub test/modules/attractor_trajectory_model_test.dart test/number_walls/number_wall_state_test.dart", "git diff --exit-code -- lib migration packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check", "( AUTOWORK_CACHE=\"${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}\" && export AUTOWORK_CACHE && export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\" && export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\" && export CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\" && export RUSTUP_HOME=\"$AUTOWORK_CACHE/rustup-1.95.0\" && test -x \"$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/cargo\" && test -d \"$CARGO_HOME/registry\" && test -x \"$FLUTTER_ROOT/bin/flutter\" && test -d \"$PUB_CACHE\" && export PATH=\"$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:/usr/bin:$PATH\" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 --json )"]
exclusions = ["No app/controller/renderer ownership switch, flag enablement, new module admission, baseline/original-oracle refresh, dependency/lock changes, new live/publication/security authority or full-M2/browser/hardware/performance qualification."]
+++

- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration; docs/tasks/RUST-PLAN-09.md#bounded-admission-and-fair-execution
- Repo obligations triggered: docs/engineering/spec.md#planned-rust-engine-boundary; ADRs 0005/0006 and original replay/last-good/exact-value gates. Maintain the designated component note. Generated/native obligations are specified in the cited plan; no source fixture refresh or platform claim follows from unit/build checks.
- Check setup: Use AGENTS.md pinned setup: absolute Git-common-directory AUTOWORK_CACHE default, Flutter 3.47.9/Dart 3.13.7 and isolated PUB_CACHE, Rust 1.95.0/CARGO_HOME/RUSTUP_HOME, private TMPDIR. Compare flutter --version with fdroid/flutter.version and verify /usr/bin/python3 pytest/jinja2/markupsafe.soft_str imports. Run flutter pub get --offline --enforce-lockfile before Flutter checks. Current FRB runtime/Dart/codegen is 2.13.0 with cargo-expand 1.0.127; do not downgrade to report-era 2.11.1. No install/profile/lock changes or ambient fallback. Runner owns merged-tree/full-main gates; focused worker checks are not a full-main pass.
- Recovery: Repair reproducible check-blocking defects within Touches without weakening assertions or provenance. Other runtime/setup/transport failures retain exact task/operation/source/evidence for the same coordinator/candidate; no replacement task, new owner interview or skipped success. Commands are proposed, unrun in planning.
- Planner call: capacity=8 counts active plus queued, not worker threads. Pure policy owns tokens/admission order, not Session state or a runtime.
- Produces: try_admit/replace/revoke/next_turn/finish policy keyed by Session+kind+generation, and reusable permit lifetime. Names/extraction reversible.
- Next action: add failing full-capacity and deterministic real-job fair-turn tests.
