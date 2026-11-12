# Check-receipt normalization for three held tasks

## Evidence and limits

This is a planning repair, not check execution or candidate acceptance. Preserve Scope,
Acceptance, Touches, Dependencies, priority and all authorization. The original mixed
prose/command Checks remain verbatim in each item's `Check protocol` note and remain
mandatory. New Checks separate executable receipts from those instructions; they do
not waive experiments or convert an omitted/failed check to success.

Read retained attempt-1 and attempt-2 reports under the Git common directory's
`autowork-execution/slot-data/<ID>/`. The latest reports identify:

- MAIN-CHECK-RESULTS-01: `20dcd625c0832af973ba5286222ef7e297ace51b`;
  seven focused Bats cases reported passing, but explicitly no full-gate execution.
  Its third acceptance item cannot be marked met by saying `full check: runner gate`.
- MAINT-DEVELOPMENT-GUIDE-PIN-01: `f11673b1fcd1dd33fc1b1857c88afb909ac7b88b`;
  ten focused cases reported passing; baseline five new failures include separate
  clone and CI selector failures. Concrete scripts were captured in attempt 1.
- MAINT-SHADER-GUIDE-BINDINGS-01: `2c044b190e1cc6a0627773ab65f747101863bd72`;
  eight focused cases reported passing; three baseline guide failures and independent
  missing-path/wrong-existing-binding controls are reported separately.

No worker PID recorded for these five reviewed items existed during inspection;
all slots were held. No engineering-repair incident or saved ledger handoff was
present. Do not edit slots, old reports, receipts or retained evidence.

## Execution and reporting protocol

Work from the execution checkout root. Set `BASE_REVISION` to the actual immutable
execution base before editing (for a retained candidate use its captured contract
base, not HEAD). Export it to private helper subprocesses. Record base and delivered
revision, exact command, exit, stdout/log reference, and experiment outcome. Keep
historical RED evidence distinct from final passing receipts. Do not reuse a prior
candidate's result to qualify a new composition. Required helpers are ordinary
worker-created private verification scripts, not repository implementation outputs;
retain their bytes and logs with the report. Do not execute missing helpers as if
successful. Recreate them from the captured sources below if scratch was removed.
Adapt baseline/CWD binding to the actual execution base, not historical unrelated
commits; preserve every assertion/experiment in the Check protocol.

For each concrete Checks string, supply a separate report receipt using that command
string. Explain manual readback and baseline experiments in its summary, not by
claiming prose was a shell command. A baseline assertion failure is expected RED
proof only when genuinely observed on unchanged guide bytes; preserve its actual
nonzero exit. The final assertions must pass independently.

### Development guide

Captured helpers inspected in place:
`/var/tmp/aw-1000-48137133-1/check_development_guide_baseline.py` and
`/var/tmp/aw-1000-48137133-1/check_development_guide.py`.

Create equivalents in task-private `$TMPDIR` under those basenames. The baseline
helper reads immutable base guide bytes via git show and substitutes only that
read in memory while running the new selectors. Require actual pytest TESTS_FAILED;
retain separate prose, standalone-clone, CI, duplicated-Dart and offline-link
failures. Existing five local-setup cases remain unchanged and passing. Never
modify original repository source fixtures to obtain RED proof.

The readback helper must compare current SDK prose, standalone clone and CI selector
with the real pin, inspect CI input syntax, verify bundled Dart against AGENTS,
resolve relative links and the common-offline-integration-gate heading, and feed
changed shell snippets to `bash -n` only. Assert all non-SDK/CI guide bytes unchanged,
changed paths confined to the two Touches, both locks/pin/existing local-setup tests
unchanged against BASE_REVISION. Neither setup recipes nor native tools run.

### Shader guide

Captured helpers inspected in place:
`/var/tmp/aw-1000-48137133-3/shader-docs-controls.py` and
`/var/tmp/aw-1000-48137133-3/shader-docs-readback.py`.

Create equivalents in task-private `$TMPDIR` under those basenames. Also create
`shader-docs-baseline.py`: use the development baseline helper's read-only
Path.read_text substitution pattern for the shader guide loaded from
`git show "$BASE_REVISION:docs/engineering/performance/SHADER_OPTIMIZATIONS.md"`.
Run the new shader tests, assert pytest TESTS_FAILED, and retain each actual failure
and pytest exit separately from the helper's successful expected-RED assertion.
This concretely receipts the required RED experiment without altering source
fixtures. Retain the RED pytest run on unchanged guide bytes before repair (or
replay final tests against immutable base guide bytes in memory, recording the
exact substitution and exit).
The controls helper must reject a missing referenced path, then change only an
in-memory multibrot4 binding to the existing powered-Buffalo shader: path validation
must pass and independent catalog-binding validation must fail. Original guide must
pass both checks. No source fixture mutation.

Readback must compare the source-case/family inventory, all live module bindings and
default powers against the three catalog Sources plus the multibrot3 catalog owner,
and both shared configurable-power formulas. Resolve every current backticked
repository path, relative Markdown link and command target. Assert source-versus-
numeric limitations and unchanged non-coloring guide bytes, compatibility commands,
broader audit and hardware/performance disclaimer. Assert the exact two-path scope
and preservation of all shader/catalog/original test/migration bytes. No render,
device or performance qualification is inferred.

### Main-check results

Use the complete root setup with only the already-supported `--json` reporting
option added to the gate invocation. Compare provisioned Flutter against the pin
and revalidate Python imports first. Run on delivered bytes; record both lock hashes
before/after, exact source and command, actual terminal JSON, each stage's exit and
overall exit in `docs/tasks/MAIN-CHECK-RESULTS-01.md`. Stopped families are NOT_RUN,
not passed. Preserve Flutter/Python/Bats/Cargo families, all timeouts, stop-on-failure
and lock guards. A real failure stays failed. Do not repair named product tests or
edit the external classifier. Runner merged-tree verification remains separate.

## Unchanged peer holds

MAINT-DESKTOP-CAPTURE-OUTPUT-01 and MAINT-PRESET-KEYBOARD-01 retain their contracts.
Their attempt-2 reports include exact declared receipts; integration receipts
`59851d81827c429cb3bee23763df5b54.json` (composition `5a29fd8c`) and
`94f6f02097e84499ac0111711d450ea9.json` (composition `c2847ec1`) both report
CHECK_FAILED/exit 1. Notices say the full check also crashed on the base:

- `[offline-gate] summary: /var/tmp/aw-r-2290027-4451dh0r/offline-gate-k72Q80/offline-gate.json`
- `[offline-gate] summary: /var/tmp/aw-r-2578135-5vdgk0so/offline-gate-A58d5G/offline-gate.json`

These notices do not establish a failing test. MAIN-CHECK-RESULTS-01 already owns
full-check observability; no duplicate repair, synthetic dependency or peer scope
expansion is justified. Retained compositions are not accepted by this review.

The historical MAIN bundle path recorded in MAIN-CHECK-RESULTS-01,
`autowork-execution/main-evidence/52fc51571717604062eb4f9e75c2eb0268107beb`,
is absent on this host during this pass. Its five files could not be reread here;
prior recorded observations remain historical, not newly verified evidence. No
new MAIN test classification or qualification is made from the missing bundle.
