# Qualification task overlap review

## Evidence boundary

Reviewed against `81bb05232f431a1b8344a38d87c573f28bc9adf6` before ledger edits.
This records contract/admission diagnosis, not executed platform qualification.

- [NUM-WALL-05](../../tasks/items/NUM-WALL-05.md): its Scope explicitly reuses
  the composed Number Walls journey; its Checks run
  `integration_test/flows/number_wall_journey_test.dart` on Android.
- [NUM-WALL-04](../../tasks/items/NUM-WALL-04.md): its Checks call that file a
  **new** integration target and its Next action creates the composed journeys.
  The target is absent at the reviewed revision. Read-only inspection of its
  live worktree found that exact target and the browser journey as untracked
  additions. NUM-WALL-03 supplies styling/export, not this integration target.
- [Accepted Number Walls plan](../engineering/spec.md#number-walls-and-modular-windows)
  and [verification ownership](../engineering/test-plan.md#number-wall-verification)
  retain Linux/browser and installed Android qualification separately. Existing
  `integration_test/flows/user_flows_test.dart` explicitly excludes screen-reader
  integration; it is not evidence of TalkBack acceptance.
- [SINEWARP-002-47](../../tasks/items/SINEWARP-002-47.md), its
  [accepted implementation/oracle plan](../engineering/spec.md#recursive-sine-warped-sphere),
  [verification plan](../engineering/test-plan.md#recursive-sine-warped-sphere-verification),
  [source study](../../research/recursive-sine-sphere.md) and
  [owner outcome](../../PRD.md#recursive-sine-warped-sphere) require the sine-sphere
  implementation and independent references, not Number Walls artifacts.
  Its existing SINEWARP-001-aa dependency remains justified.

## Worker and admission evidence

At inspection, neither NUM-WALL-05 nor SINEWARP-002-47 had a worker slot or
slot-data directory, hence neither had a saved worker report to review.
NUM-WALL-04 had a running slot and a matching live worker process (PID 1781360).
Its saved `slot-data/NUM-WALL-04/attempt-1/contract.txt` confirms the new native
journey target. No final `report.json` existed; `worker.log` contained only the
startup linked-path message. Its contract and active work were left untouched.
All execution evidence was read in place under `.git/autowork-execution/`.

The installed scheduler release `f94c45e267d89f2670a3ee8d249d3b6daada92f8`,
`Src/pi_autowork/engine/parallel_plan.py` (`_files`, `plan`, `conflict`), counts
literal files across unfinished contracts, including noncandidates and unlanded
live slots. Three or more make a non-test-module path hot; held peers alone do
not reserve files. Directories/globs/cold files rank work rather than create
file gates. Resource and protected-path admission remains independent.

Nine unfinished records named the exact `docs/engineering/test-plan.md` path:
BESICOVITCH-01, FIB-PRIME-03, GAUSS-MOAT-03-QUALIFY-LIVE,
GAUSS-MOAT-04-GROWTH-LIVE, NUM-WALL-04, NUM-WALL-05,
QUAT-NORM-03-QUALIFY-LIVE, RELEASE-001-23-LIVE and SINEWARP-002-47.
Thus both reported hot-file waits against live NUM-WALL-04 are legitimate.
`tasks why` reported both tasks eligible in the task graph before editing;
that graph-only result does not override live file/resource admission.

## Disposition

- **NUM-WALL-05:** retain NUM-WALL-03 and add NUM-WALL-04 as the producer of
  the explicitly reused native integration journey. This corrects a missing
  artifact prerequisite, not the shared documentation overlap. Keep all Scope,
  Acceptance, Checks, Touches, resources, authorization, section and rank intact.
  Android/TalkBack/gallery results remain independently required; missing
  hardware remains NOT_CHECKED.
- **SINEWARP-002-47:** no contract edit. Do not add a Number Walls dependency,
  narrow Touches, split acceptance or reorder it merely to bypass overlap.
- Do not split or alter running NUM-WALL-04, certify either unverified goal,
  apply any candidate ledger patch, or alter runtime state. No candidate ledger
  proposal was supplied for these two unstarted tasks.

## Validation and revisit trigger

`tasks validate --worktree .` passed before and after editing (113 tasks,
20 goals; the edited task is correctly listed as pending before commit).
`git diff --check` passed. A focused comparison with HEAD confirmed that
Dependencies is the only changed header field, NUM-WALL-04/SINEWARP-002-47 and
both goal records are unchanged, and the audit's local links/anchors resolve.
No Flutter/device/browser result is claimed by this documentation review.

Revisit admission after NUM-WALL-04 lands and the runner recomputes its plan;
landing does not prove Android or sine-sphere qualification or remove other
resource/protected-path gates. A different journey producer or a changed reuse
contract would require fresh source evidence before changing Dependencies.
