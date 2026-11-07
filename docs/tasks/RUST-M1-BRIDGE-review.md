# RUST-M1-BRIDGE — executable offline setup repair

## Retained evidence

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

## Concrete remaining change

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
