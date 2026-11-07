+++
schema = 1
id = "RUST-M2-SEEDED-RANDOM"
title = "Port pinned Dart VM seeded draws and pure schema randomization targets"
short = "Port exact seeded randomization"
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 2000
depends_on = ["RUST-M2-RANDOM-ORACLE", "RUST-M2-NORMALIZATION"]
touches = ["rust/crates/fractal-core/src/lib.rs", "rust/crates/fractal-core/src/seeded_random.rs", "rust/crates/fractal-core/src/param_randomization.rs", "rust/crates/fractal-core/tests/param_randomization.rs", "docs/tasks/RUST-M2-SEEDED-RANDOM.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Implement the pinned VM seed mixer/MWC/draw operations and pure ordered-schema general/Number Walls target helpers from SDK source and unchanged Dart randomizer. Consume exact randomization.json draw/target expectations, including synthetic schemas at the pure seam only. Reuse shared normalization, add focused public tests and result/limits note. No Session owner."
acceptance = ["Given param_randomization tests and pinned VM math_patch.dart bound by randomization.json, wrapping signed-64 seed mixing, four warm-ups, MWC 0xffffda61 and nextInt rejection/power-of-two paths reproduce every recorded general and wall draw exactly. nextInt accepts 1..2^32, rejects other bounds without consuming state; nextDouble and nextBool match exact recorded values, not fitted lookup tables or rand.", "Given the same public pure tests over all 18 general and 15 wall cases, schema-order palette no-draw behavior, all five types/enum underlying kinds, Julia radius .35, inclusive integer bounds, step/six-decimal cleanup, wall seed masking/source/colors/custom prime and six-prime opt-in reproduce target params exactly. Synthetic schemas remain test inputs, not approved Session modules.", "Given focused Rust and unchanged Dart oracle checks, source bindings and original fixtures/locks/production owners stay unchanged. The component note names API, source/version, exact checks and still-pending Session undo/timeline/browser/native proof; no dependency or entropy service is added."]
checks = ["PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\" cargo test --manifest-path rust/Cargo.toml -p fractal-core --test param_randomization --test normalization --locked --offline", "( export PATH=/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$PATH; export CARGO_HOME=\"$AUTOWORK_CACHE/cargo-1.95.0\"; scripts/ci/rust-check.sh )", "flutter test --no-pub test/migration/randomization_oracle_test.dart test/number_walls/number_wall_randomizer_test.dart", "git diff --exit-code -- lib migration rust/Cargo.lock pubspec.lock packages && git diff --check", "( AUTOWORK_CACHE=\"${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}\" && export AUTOWORK_CACHE && export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\" && export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\" && test -x \"$FLUTTER_ROOT/bin/flutter\" && test -d \"$PUB_CACHE\" && export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No Session/bridge/app/renderer/flag/persistence/dependency/lock/original-fixture changes, unseeded/secure RNG, browser/cross-version equivalence or native/hardware/full-M2 qualification."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration; docs/tasks/RUST-PLAN-08.md#seeded-rng-and-pure-randomization
- Consumes: migration/oracles/randomization.json and its pinned SDK sources; lib/core/controllers/params/fractal_param_randomizer.dart and shared normalizer.
- Produces: seeded generator plus pure ordered-schema target helpers returning typed parameter maps for RUST-M2-RANDOM-STATE and future animation.
- Planner call: generator/helper names and extraction are reversible; exact draw/target semantics are not. Reject unsupported bounds explicitly; do not fit captured values.
- Repo obligations triggered: docs/engineering/spec.md#planned-rust-engine-boundary; ADR 0005; maintain designated component note. No generated output, live authority or source fixture refresh.
- Next action: add failing public oracle draw/target comparison before porting the pinned algorithm.
- Check setup: Use AGENTS.md pinned offline setup: existing Flutter 3.47.9/Dart 3.13.7 and isolated PUB_CACHE, Rust 1.95.0/CARGO_HOME, private TMPDIR. AUTOWORK_CACHE defaults to absolute Git common directory/autowork-execution/cache. Compare flutter --version with fdroid/flutter.version; verify /usr/bin/python3 pytest/jinja2/markupsafe.soft_str imports; flutter pub get --offline --enforce-lockfile before Flutter checks. No installs/profile changes or ambient-cache fallback. Android compile uses existing cached target-enabled RUSTC. Runner owns merged-tree/full-main gates, not repeated worker full-suite loops.
- Recovery: Repair reproducible task-check-blocking defects inside Touches without weakening assertions/provenance. Other setup/runtime failures retain exact task/operation/source/evidence for the same coordinator/candidate; no replacement task, new owner interview or skipped success. Proposed checks are unrun in planning.
