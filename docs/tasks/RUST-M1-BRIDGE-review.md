# RUST-M1-BRIDGE — offline review repairs

## Current finding: startup probe bypasses structured logging

The latest retained review is integration
`72b572baa72bc6da0b2d129cb5012b769cbdc6a8`, candidate
`af094297a235ceaade3ba1f2416c38a685cd9fe6`. Read in place under
`/home/xel/.local/state/pi-autowork/481371330a53e93e/`:

- `review-findings/RUST-M1-BRIDGE.json` and
  `full-check/tree-a83b2819ac878ba3219841d187766a22ca4f31bd.json/.log`:
  locked offline resolution and analysis passed; Flutter tests exited 1. The
  terminal summary names `test/diagnostics/structured_logging_policy_test.dart`,
  case `production diagnostics use structured logging` (3496 passes, 9 skips,
  1 failure). No isolated reruns or flaky classification are recorded.
- `full-check/base-tree-c7c333e7752f4f469c4f8b2040bc2cbef289808d.json`
  records exit 0 on base `b89c8872e98ea2517ee5ad3d6ba44089d3b9cbbc`
  using the same self-contained command. The old cache-resolution blocker is
  not the current failure.
- The receipt's temporary summary directory
  `/var/tmp/aw-r-3183881-ki_qeb08/offline-gate-xOcuAa/` no longer exists.
  The retained log still contains the failing-test summary. Its JSON `failures`
  array is empty and the gate progress calls this "before any test result";
  neither overrides the actual retained Flutter stage result.
- The two slot reports in `attempt-1/report.json` and `attempt-2/report.json`
  now describe retained candidates `683ba346d776426f1fc8cf20687ad750f1c26f9f`
  and `af094297a235ceaade3ba1f2416c38a685cd9fe6`. Their focused successes
  do not qualify the failed merged-tree gate.

Source inspection explains the failure without changing the policy: candidate
`lib/main.dart:40` adds `debugPrint` in `_probeRustEngine`. The policy scans
production `lib/`, permits only its existing logger sinks and explicit PLAYWRIGHT
protocol output, and rejects this call. The existing
`lib/core/services/diagnostics/logging/app_logger_service.dart` provides
`AppLogger.instance.info` with structured `data`; it can record in memory before
persistence initialization. No new logger, sink exception or product decision is
needed. `lib/main.dart` is already in Touches; the policy is a read-only check.

### Remaining worker change and verification

1. Reuse the retained bridge and its working Git-common-directory cache discovery;
   do not replace the setup with the historical required-variable-only example
   below. Preserve current task planning when reusing candidate documentation.
2. Route the opt-in version/rendering probe through the existing AppLogger API,
   keeping version and rendering capability observable as structured data. Keep
   default-off/Web no-load, `finally` shutdown, error propagation, safe/boot modes
   and legacy rendering unchanged. Do not weaken the logging policy, exempt
   `main.dart`, suppress the finding or rewrite generated glue to fix this call.
3. With the pinned process-local SDK/cache, run
   `flutter test --no-pub test/diagnostics/structured_logging_policy_test.dart`,
   then every existing task Check, including both Web flags, native fixture
   builds, deterministic codegen and the M0 guards. Run the extracted full
   declaration on the delivered composition, retaining all stage results and
   lockfile integrity. No repaired-candidate pass is claimed here.
4. Keep installed Linux/Waydroid/browser qualification separate and pending; no
   M1 or goal qualification follows from this documentation repair.

At inspection the slot is held for validation, its recorded worker PID is absent,
its check outcome is CHECK_FAILED, and it is not a successful candidate awaiting
landing. Keep the original Acceptance, Dependencies, priority and authorization.

Maintainer validation: task-store validation passed (124 tasks, 21 goals).
A policy-equivalent static scan found zero violations at base b89c8872 and exactly
`lib/main.dart:40` at both af094297 and 72b572ba. Receipt log SHA-256 and
base/candidate command equality, preserved task-contract fields, local link targets
and `git diff --check` passed. No Flutter suite or candidate repair ran here.

## Historical setup evidence (not the latest blocker)

Inspected in place; no runtime records or candidate patches were applied:

- `.git/autowork-execution/slot-data/RUST-M1-BRIDGE/attempt-1/report.json`
  (candidate `f0138eca0e4cabc06ab3eb0a6542559c39fc4bca`) and
  `attempt-2/report.json` (candidate
  `f996c1c48ae357ada055eba1e07d60b5d13a35b2`).
- Runner state `/home/xel/.local/state/pi-autowork/481371330a53e93e/`:
  `review-findings/RUST-M1-BRIDGE.json`,
  `full-check/RUST-M1-BRIDGE-merged.log`, and
  `full-check/tree-b46cfb7c095d68704b30c808950459563aa28d97.json`
  bind the last rejection to integration
  `982f3f1665c94aefeadbb13ea17cd86888ae5e37`.
  The earlier `tree-944706f4c1ade986824ee5e3a4e253e0f32f5893.json`
  binds the same resolver failure to integration
  `b1fec92f72e22881bfaefc345834eba293923360`.
- The resolver says `flutter_rust_bridge 2.11.1` does not match any available
  versions, then `Failed to update packages.` Both records report exit 1 and
  no test failures/results. They are not evidence of a failing application test.
- Attempt 2 reports successful locked offline resolution with explicit provisioned
  SDK/cache and unchanged lock SHA-256
  `d919ab7eb6ad10b5939c81092b6f1657ba84642109ca677684184ccf30c55451`.
  Local read-only inspection confirms FRB 2.11.1 and build_cli_annotations 2.1.1
  exist in `.git/autowork-execution/cache/pub-cache/hosted/pub.dev/`, while
  `/home/xel/.pub-cache/hosted/pub.dev/` contains no FRB package.
  This is setup evidence, not a passing merged-tree gate.

Sources: [accepted migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[common gate](../../AGENTS.md#common-offline-integration-gate),
[existing setup mechanism](MAIN-CHECK-01.md#reproducible-process-local-invocation),
and `scripts/ci/offline-gate.sh`. MAIN-CHECK-01's historical SDK numbers are not
current pins; use `fdroid/flutter.version` (3.47.9) and the current AGENTS setup.

## Historical setup repair (retain the candidate's newer cache discovery)

The task's Checks already export the correct environment. The runner's full-check
receipt instead records the bare AGENTS `Full check:` command, without the
following Setup prose. Adding the same setup only to the spec/report again cannot
repair that executable path.

Make the root AGENTS declaration self-contained, selecting the already-provisioned
SDK and cache process-locally, with every existing offline family retained. The
existing `scripts/ci/offline-gate.sh` performs SDK identity, offline locked pub get,
lockfile integrity, analyzer, Flutter tests, Python tests and Bats. One suitable
single-line declaration is:

```sh
Full check: ( : "${AUTOWORK_CACHE:?provisioned cache required}" && export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9" && export PUB_CACHE="$AUTOWORK_CACHE/pub-cache" && export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH" && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 )
```

The retained runner release's `Src/pi_autowork/main_check.py:39-55` extracts only
that line (unless PI_AUTOWORK_VALIDATE explicitly overrides it), and treats a
semicolon as the start of trailing commentary. Use `&&`, not semicolons, in the
declaration. Verify actual extracted-command equality and shell syntax; do not
change runner state, overrides or caches to manufacture acceptance. Preserve the
Setup import preflight, fail-closed behavior and offline/live separation. Do not
use skip flags, weaken dependency constraints, upgrade tools or install into the
ambient cache. Missing provisioned inputs remain an explicit setup failure.

Retain/reuse the candidate's bridge implementation rather than replace working
code merely to produce a diff. The worker names the generated Linux plugin list
and nine M0 JSON files as necessary consequences of the path dependency. Touches
now names these exact files. For intentional M0 refresh, use the existing scratch
export/capture procedures twice and review before promotion: inventory payloads,
replay inputs/expected outputs, image bytes/pixels and shader/settings bindings
must remain unchanged. Only dependency provenance and resulting manifest hashes
may change; never automatically repin evidence to conceal semantic drift.

## Verification required on the repaired composition

1. Revalidate Flutter against `fdroid/flutter.version`, the Python imports from
   AGENTS Setup, and the provisioned dependency cache. Preserve lock hashes.
2. Verify the actual runner extracts the entire self-contained declaration;
   syntax-check it and compare its stages with the previous full check. A
   PI_AUTOWORK_VALIDATE override, if present, must be reported rather than edited.
3. Run locked offline resolution and the existing adapter, Rust lifecycle,
   deterministic generation, native fixture builds and both Web builds from the
   task. Run `flutter test --no-pub test/migration` to retain M0 guards.
4. Run the declared complete offline gate on the delivered composition, retaining
   terminal stage results and unchanged lock hash. The worker's focused passes
   cannot substitute for the runner's merged-tree gate. No full gate was run by
   this documentation maintainer; all repaired-composition checks remain pending.
5. Linux/Waydroid installed lifecycle and browser journeys remain separate and
   unrun. Neither this repair nor build success qualifies M1 or the goal.

The slot was held for validation, not running or awaiting landing; both recorded
worker PIDs were absent at inspection. The task stays open in Next with its
original Acceptance, Dependencies and authorization. No product decision or new
live authority is needed for this bounded offline setup repair.

Maintainer checks: task-store validation passed (124 tasks, 21 goals); the actual
runner regex extracts the complete proposed declaration, `bash -n` accepts it,
local documentation links resolve, and comparison with HEAD preserves original
Acceptance, Dependencies, priority, resources, exclusions and every prior Check.
`git diff --check` passed. These documentation checks do not qualify the candidate.
