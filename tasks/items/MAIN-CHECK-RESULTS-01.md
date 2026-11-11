+++
schema = 1
id = "MAIN-CHECK-RESULTS-01"
title = "Restore observable terminal results from the full offline check"
short = "Restore observable terminal results f..."
status = "open"
goal = "APP-QUALITY-001"
section = "Now"
rank = 1000
depends_on = []
touches = ["AGENTS.md", "scripts/ci/offline-gate.sh", "test/scripts/offline_gate.bats", "docs/tasks/MAIN-CHECK-RESULTS-01.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Make the existing full check report its actual stage results rather than ending as an ambiguous summary-path crash. First restate the root Full check invocation using the supported --json output and existing pinned process-local setup; change gate reporting only if required to expose complete failure diagnostics and terminal exits. Preserve the gate implementation, all families, fail-closed setup, timeouts, stop-on-failure and both lock guards. Follow docs/tasks/MAIN-CHECK-RESULTS-01.md; investigate the observed metadata/log discrepancy, not product code or named test repairs."
acceptance = ["The documented full check emits explicit terminal verdict, failed stage and stage exits with failure diagnostics observable without relying solely on a private summary pathname. Use the existing --json interface where sufficient; retain complete private stage logs and genuine nonzero exits. No test name from this check-broken notice becomes a repair contract.", "Executable-double regressions prove passing, failing and long-output failure results are observable and consistent with summary/logs; setup failures, timeouts, lock drift and stopped later families cannot become successful checks. All current stage commands and safety constraints remain.", "Run the complete root full offline check with the pinned existing setup on delivered bytes, recording source/command, actual stage results, exit and both lock hashes in the task note. A real test failure remains a failed gate, not INCOMPLETE by omission, and is not repaired here. Preserve existing closures, goals and all live/publication gates; no external runner or runtime-state edits."]
checks = ["bash -n scripts/ci/offline-gate.sh && bats test/scripts/offline_gate.bats", "Run the complete AGENTS.md Full check from the execution checkout root, preserving all setup and Flutter/Python/Bats/Cargo families and both lock guards; use explicit terminal JSON reporting as documented in docs/tasks/MAIN-CHECK-RESULTS-01.md. Compare Flutter with fdroid/flutter.version and revalidate /usr/bin/python3 pytest/jinja2/markupsafe.soft_str imports first. Record genuine failures and NOT_RUN stages, not skipped success.", "git diff --check; verify pubspec.lock and rust/Cargo.lock unchanged and no product, oracle fixture or external runner changes."]
exclusions = ["No product/test-name repair, fixture/source-binding refresh, tool upgrade/install, runner/runtime-state change, reclassification by editing evidence, reopened producer, or goal/live/publication qualification."]
+++
- Sources: AGENTS.md#common-offline-integration-gate; docs/engineering/test-plan.md#common-offline-gate; scripts/ci/offline-gate.sh; test/scripts/offline_gate.bats; docs/tasks/MAIN-CHECK-RESULTS-01.md
- Evidence: MAIN check-broken at 52fc51571717604062eb4f9e75c2eb0268107beb (last green c026454f2cc3926665b55f68b997f7bb932a8fe4); reported twice; crash line: [offline-gate] summary: /tmp/aw-main-tdak8u69/offline-gate-n1RglI/offline-gate.json. Bundle read in place: /home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/52fc51571717604062eb4f9e75c2eb0268107beb. Metadata broken/INCOMPLETE, failures=null; log actually reaches Flutter test failure results (+3493 ~9 -1), after passing pub-get/Cargo/analyzer. Exit 1, empty isolated-reruns log, flaky_history={}; no proven crashing tool. Resolve reporting discrepancy without adding test-name repairs; detailed source evidence and bounded approach: docs/tasks/MAIN-CHECK-RESULTS-01.md.
