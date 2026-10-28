# ACAD-013-4142ef42 — contract repair deferred for active execution

Inspected at **2026-10-28T00:11:50Z**, checkout `382101811408fb3829951bfcc4c1dff607eab7a7`.

## Finding

[`tasks/items/ACAD-013-4142ef42.md`](../../tasks/items/ACAD-013-4142ef42.md)
is open. Its Scope, Acceptance and Checks already exist; only the empty
`touches` array makes it a draft. Creation commit `d7a6b2e7` contains no Sources
note or linked accepted plan. No task-specific slot-data directory, worker report
or saved ledger patch was found for this ID.

Read the goal's accepted source, [PRD active release contract](../../PRD.md#active-release-contract),
and the [standing Waydroid target contract](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target).
The latter requires coordination with active workers and keeps emulator evidence
separate from release qualification.

## Active execution evidence

Read-only inspection found the exact recovery work already executing outside a
runner slot:

- Private bundle: `/tmp/fractal-waydroid-recovery-HD7WWt/`, identified by
  `/tmp/fractal-waydroid-recovery-current-path`.
- Live Pi process **3876769** owns shell **1534910**, probe shell **1534912**,
  timeout **1535011** and ADB **1535014**. At inspection the probe had run 725
  seconds. Its command selects the designated Waydroid transport, matching
  disposable-device acknowledgement, candidate **1.1.112 / 112**, and **1800 seconds**.
- `scripts/soak-probe.sh` in that private bundle performs stale-Monkey cleanup and
  an installed-candidate interaction soak. `probe.log` records readiness, cleanup,
  launch and soak start; periodic evidence exists. `probe.exit` is absent.
- The partial Monkey log contains a launcher crash. There is no terminal outcome;
  neither success nor completed Acceptance can be inferred from these logs.

## Disposition and next action

**Blocked by active execution, not a missing owner decision.** The maintainer's
explicit no-edit rule covers tasks with a live worker, even without a runner slot.
Leave this task entry, authorization, priority, dependencies and goal status
unchanged. Do not interrupt the probe, copy its evidence, or launch another soak.

After actual worker inactivity and a terminal report are established, reread the
current task and retained evidence before repairing Touches through the task CLI.
Use the worker's actual private output boundary; do not add production-code paths
or infer new authority merely to make the task selectable. Retain the actual soak
failure if one occurs; do not close or qualify the task from an in-progress run.

## Maintainer verification

The initial `tasks validate --worktree .` returned `ok: true`, 105 tasks and 20
goals, with this task as the sole draft (`touches`). This note is an inspection
record only, not a task repair, worker report, device test or qualification receipt.
