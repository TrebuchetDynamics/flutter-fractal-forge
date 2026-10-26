# Owner removal of 22 held tasks — 2026-10-26

## Decision

After being offered the remaining groups (15 device/hardware checks, four academic reviews, one Linux image review and two release tasks), the user instructed: **“Remove all”**. Remove those **22 held tasks**, not the four runnable implementation tasks.

This supersedes the queue-retention instructions in [the unblock decision](UNBLOCK-20261026.md) and [the earlier delegated decision](DELEGATED-DECISIONS-20261025.md). Removal is an owner backlog decision, **not completion, accepted visual/mathematical review, platform qualification, a release waiver or production authority**. Existing goal statuses and technical acceptance requirements remain unchanged and unverified where evidence is absent.

Do not automatically recreate these tasks, copies of their holds or replacement approval questions after the four local tasks finish. Record remaining evidence limits in results/docs. Reintroducing this removed backlog requires a new explicit owner request; no requirement is silently certified by its absence from the task store.

## Removed IDs

- ACAD-01-LIVE
- ACAD-02-LIVE
- ACAD-03
- ACAD-04
- CAT-QUALITY-01-LIVE
- CAT-QUALITY-02-LIVE
- GAUSS-MOAT-02-WALK-LIVE
- GAUSS-MOAT-03-QUALIFY-LIVE
- GAUSS-MOAT-04-GROWTH-LIVE
- ICON-ZJ-02
- QUAT-NORM-01-SLICE-LIVE
- QUAT-NORM-02-WALK-LIVE
- QUAT-NORM-03-QUALIFY-LIVE
- REL-JOURNEY-02-LINUX-LIVE
- REL-JOURNEY-03-ANDROID-LIVE
- RELEASE-001-23-LIVE
- RELEASE-003-ae
- SMOOTH-001-INVENTORY-01-LIVE
- SMOOTH-001-INVENTORY-02-LIVE
- VIEW-UI-01-LIVE
- VIEW-UI-02-LIVE
- VIS-003

## Preserved work and history

Keep QUAL-EXPORT-REPAIR-01, GAUSS-LOCAL-01, QUAT-LOCAL-01 and FIB-PRIME-03 runnable with their existing implementation contracts. No worker stop/restart, worktree deletion, evidence deletion or remote publication is part of this change.

The removed records remain available in Git at baseline `0bfdd690`; for example, `git show 0bfdd690:tasks/items/ACAD-03.md`. Historical evidence packets and decision tables intentionally retain the IDs/links from their original snapshots. Their task links may no longer resolve in the current checkout; use that baseline for historical readback rather than editing frozen receipts or recreating deleted tasks to make old links resolve. Public research metadata, images, private evidence and all other existing artifacts remain untouched.

## Verification scope

Passed: supported task-store validation (99 tasks, 20 goals, no drafts), a baseline comparison proving exactly the listed 22 records removed, all surviving task headers and goal bytes unchanged, four executable candidates preserved, no surviving dependency referencing a removed ID, and diff-whitespace checks. The supported deletion API reported the running coordinator lease; no workers, leases, worktrees or evidence were stopped or deleted. This is a queue-only removal, not an application-test or live-qualification result.
