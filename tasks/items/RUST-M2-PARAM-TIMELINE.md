+++
schema = 1
id = "RUST-M2-PARAM-TIMELINE"
title = "Own ordered explicit parameter ticks and replacement cancellation inside inert Session"
short = "Own ordered parameter timeline"
status = "done"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 3000
depends_on = ["RUST-M2-INTERPOLATION", "RUST-M2-SESSION"]
touches = ["rust/crates/fractal-core/src/session.rs", "rust/crates/fractal-core/src/session_param_timeline.rs", "rust/crates/fractal-core/tests/session_param_timeline.rs", "rust/crates/fractal-core/tests/session_replay.rs", "docs/tasks/RUST-M2-PARAM-TIMELINE.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Add inert core complete-target start/replace/cancel/one-logical-tick seams using interpolate_parameters. Keep hidden from/target/step/generation in the Session transactional owner with checked revisions and source-matched cancellation hooks. Compare actual-module interpolation oracle outputs and preserve pure synthetic kernel coverage. Add public timeline tests/result note; no clock, external timer, morph or generated/app route."
acceptance = ["Given session_param_timeline tests over actual-module param-interpolation.json outputs/replacement, explicit ordered ticks reproduce steps 0..36 (float tolerance 1e-12, other values exact). Each callback advances at most one step; complete target assignment, replacement from partial current state and stopped-generation rejection match source. No catch-up by elapsed wall time or Dart-computed intermediate state.", "Given composed transaction/cancellation tests, known Param edits, preset/load/module/resetParams/resetSession cancel, scalar camera/resetView alone do not; explicit cancel is idempotent and stale tokens cannot advance a replacement. Rejected mixed batches, wrong identity/stale revision and checked overflow preserve both visible params and hidden timeline; retained snapshots stay immutable.", "Given original replay, pure interpolation and unchanged fake-time Dart oracle checks, all 68 outputs stay unchanged and no fixture/production Dart/bridge/lock/flag changes occur. Result note distinguishes 36 scheduled 16-ms callbacks from measured 600-ms timing and leaves morph, physical animation, timer transport and full ownership pending."]
checks = ["PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\" cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_param_timeline --test param_interpolation --test session_replay --locked --offline", "( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; export CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\"; scripts/ci/rust-check.sh )", "flutter test --no-pub test/migration/param_interpolation_oracle_test.dart test/fractal/fractal_controller_behavior_test.dart", "git diff --exit-code -- lib migration packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check", "( AUTOWORK_CACHE=\"${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}\" && export AUTOWORK_CACHE && export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\" && export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\" && test -x \"$FLUTTER_ROOT/bin/flutter\" && test -d \"$PUB_CACHE\" && export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No production Dart/bridge/generated/fixture/lock changes, RNG dependency, morph/celebration/haptic/physical/scheduler ownership, app/render/flag switch or native/browser/hardware/full-M2 qualification."]
closure = "coordinator_verified"
closure_evidence = "tasks/evidence/RUST-M2-PARAM-TIMELINE.toml"
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration; docs/tasks/RUST-PLAN-08.md#ordered-parameter-timeline
- Consumes: RUST-M2-INTERPOLATION kernel and migration/oracles/param-interpolation.json; controller cancellation call sites including resetView without timer cancellation.
- Produces: complete typed target plus logical-tick Session API with transactional hidden generation/step state, for later randomization/app event transport.
- Planner call: target/tick seams are inert core APIs; API names reversible. No prerequisite on RNG because target maps already exist in the oracle. Keep unsupported synthetic schemas in pure tests only.
- Repo obligations triggered: docs/engineering/spec.md#planned-rust-engine-boundary; existing replay/last-good invariants; designated component note only, no generated output.
- Next action: add failing public oracle tick/replacement and mixed-batch rollback tests.
- Check setup: Use AGENTS.md pinned offline setup: existing Flutter 3.47.9/Dart 3.13.7 and isolated PUB_CACHE, Rust 1.95.0/CARGO_HOME, private TMPDIR. AUTOWORK_CACHE defaults to absolute Git common directory/autowork-execution/cache. Compare flutter --version with fdroid/flutter.version; verify /usr/bin/python3 pytest/jinja2/markupsafe.soft_str imports; flutter pub get --offline --enforce-lockfile before Flutter checks. No installs/profile changes or ambient-cache fallback. Android compile uses existing cached target-enabled RUSTC. Runner owns merged-tree/full-main gates, not repeated worker full-suite loops.
- Recovery: Repair reproducible task-check-blocking defects inside Touches without weakening assertions/provenance. Other setup/runtime failures retain exact task/operation/source/evidence for the same coordinator/candidate; no replacement task, new owner interview or skipped success. Proposed checks are unrun in planning.
- Pending live: Native/browser/hardware timing and full animation qualification remain pending under RUST-PLAN-08; explicit logical ticks and Dart fake time do not establish measured 600-ms timing. No app/bridge route or device operation was introduced.
