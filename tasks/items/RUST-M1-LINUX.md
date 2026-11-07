+++
schema = 1
id = "RUST-M1-LINUX"
title = "Execute and retain the installed Linux Rust probe lifecycle"
short = "Close the missing Linux M1 runtime-proof gap through the reserved-port driver."
status = "open"
goal = "RUST-ENGINE-001"
section = "Now"
rank = 2000
depends_on = ["RUST-M1-BRIDGE"]
touches = ["integration_test/migration/rust_engine_smoke_test.dart", "docs/tasks/RUST-M1-LINUX.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the existing actual-native Rust smoke fixture with RUST_CORE=true through scripts/run-native-integration.sh in an owned Linux/Xvfb process. Retain terminal driver output, run.json, source/build/toolchain/backend identity and cleanup in persistent private evidence linked by docs/tasks/RUST-M1-LINUX.md. Reuse the fixture's version, rendering=false and independent-handle lifecycle assertions. Only add bounded fixture instrumentation if needed for observable native results; do not weaken assertions. A build or supplemental flutter run is not a native pass. Report exact failures/setup refusals and preserve their logs; M1 is not qualified unless both native targets pass. No production behavior or controller/render migration."
acceptance = ["Given the existing native smoke fixture and actual worker port lease, the official integrationDriver completes the real Linux bridge test with version 0.1.0, rendering=false, session isolation, duplicate shutdown and closed-handle rejection; run.json records exit_code 0, protocol_success true and cleanup.remaining_pids empty.", "Given retained evidence, docs/tasks/RUST-M1-LINUX.md identifies tested revision, target/driver/wrapper and native-library hashes, pinned SDK/Rust/FRB, actual backend, command, terminal outcome and evidence paths that survive task scratch cleanup. Build-only, software versus hardware, Waydroid and full-goal claims remain distinct; any refusal/failure stays explicitly failed, not an M1 pass."]
checks = ["flutter test --no-pub test/migration/rust_engine_adapter_test.dart", "autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_engine_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true", "Read the emitted native-integration evidence directory: require run.json exit_code=0, protocol_success=true, cleanup.remaining_pids=[] and official protocol-success.json allTestsPassed=true; retain the full driver.log and source/build/backend hashes. Run git diff --check. Missing real AUTOWORK_PORT_BASE/private TMPDIR must refuse before launch.", "( AUTOWORK_CACHE=\"${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}\" && export AUTOWORK_CACHE && export FLUTTER_ROOT=\"$AUTOWORK_CACHE/flutter-3.47.9\" && export PUB_CACHE=\"$AUTOWORK_CACHE/pub-cache\" && test -x \"$FLUTTER_ROOT/bin/flutter\" && test -d \"$PUB_CACHE\" && export PATH=\"$FLUTTER_ROOT/bin:/usr/bin:$PATH\" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )"]
exclusions = ["No raw flutter test -d linux, arbitrary ports, SDK edits, unrelated process cleanup, device mutation, production migration, publication or M0 refresh."]
+++

- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration; docs/tasks/RUST-PLAN-02.md#next-executable-batch
- Consumes: RUST-M1-BRIDGE installed-build glue and integration_test/migration/rust_engine_smoke_test.dart. Produces: source-bound Linux native outcome in docs/tasks/RUST-M1-LINUX.md plus retained private logs/receipt; a failed run is not M1 qualification.
- Planner call: existing headless owned Linux driver, official terminal response and actual worker-provided port allocation. No coordinator receipt, hardware claim or new authority is required for isolated local execution.
- Repo obligations triggered: docs/engineering/spec.md#planned-rust-engine-boundary and docs/engineering/runbook.md#owned-linux-runtime-with-reserved-ports. Preserve smoke version/rendering/lifecycle assertions and default-off production behavior. Update only the task result owner; no generated artifacts/manifests or saved formats change.
- Check setup: use root AGENTS.md pinned offline setup, compare flutter --version with fdroid/flutter.version and verify /usr/bin/python3 pytest/jinja2/markupsafe imports. Use existing Rust 1.95.0 through task-local PATH, existing cargo/codegen cache and private TMPDIR. Missing tool/target/cache, timeout or failed assertion is failure, not skipped success. The runner owns merged-tree/full-main verification; the Full check entry is required there, not another worker full-suite loop.
- Next action: execute the existing smoke through the wrapper and retain its terminal receipt, not another probe implementation. An observed product/glue defect outside Touches is returned with exact failing operation/source for supported contract repair; no blanket waiver or duplicate task.
