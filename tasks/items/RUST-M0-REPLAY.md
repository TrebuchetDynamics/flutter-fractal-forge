+++
schema = 1
id = "RUST-M0-REPLAY"
title = "Capture deterministic camera parameter and precision replay corpus"
short = "Freeze Dart semantics before any state owner moves."
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 3000
depends_on = []
touches = ["test/migration/state_replay_test.dart", "test/migration/support/replay_codec.dart", "migration/baseline/state-replay.json", "migration/baseline/precision-replay.json", "docs/planning/refactor-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Add a versioned JSON replay corpus and one Flutter test harness that executes current controller, parameter normalization, preset/reset and precision policy APIs. Cover ordinary and Cantor zoom bounds, pan/rotation, NaN/infinities as tagged input operands, adaptive iterations, boolean/enum values, exact Number Walls decimal ingress and stale candidate rejection. Deterministic ordered events include module switch, preset/history-compatible snapshots and resets. Precision vectors include threshold lower/equal/upper neighbors, supported power changes, actual CPU capabilities and both hysteresis history states. Preserve production code."
acceptance = ["Given stored input sequences, state_replay_test.dart recomputes existing public Dart snapshot/parameter outputs and rejects a deliberately altered expectation; exact integer strings and finite last-good semantics do not use lossy JSON numbers.", "Given precision boundary/history vectors, the same harness checks renderPath, tier, exactness and fallback-pending state against current policy; capability absence never becomes CPU precision."]
checks = ["flutter test --no-pub test/migration/state_replay_test.dart test/fractal/fractal_controller_behavior_test.dart test/fractal/fractal_controller_clamp_test.dart test/fractal/fractal_controller_boolean_clamp_test.dart test/fractal/fractal_controller_reset_session_test.dart test/core/controllers/fractal_controller_state_exposure_test.dart test/renderer/precision_ladder_policy_test.dart test/number_walls/number_wall_state_test.dart", "( export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\"; export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\"; export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\"; flutter --version && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No state/render replacement, ID renames, saved-data schema changes, publication or live device mutation in this offline task.", "Do not edit the seven pre-existing dirty test files; use isolated execution and preserve their work."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Planner call: nonfinite input uses tagged operands, never invalid JSON; snapshots retain existing serialized shapes. No new gesture math, precision ceiling or random timing. Use deterministic public API events and await actual candidate completion.
- Produces: state-replay.json and precision-replay.json with schema=1, source bindings, ordered inputs and expected outputs for later Rust parity.
- Repo obligations triggered: spec.md State and persistence and Number Walls replay validation boundary; preserve controller_behavior_test.dart:12-25 and input bounds:14-18, policy hysteresisFrames=2 at line122. Update migration evidence only; generated corpus/test helper in touches, no CI/manifest/production changes.
- Next action: create replay test against current Dart APIs before recording fixtures. Proposed checks are unrun.