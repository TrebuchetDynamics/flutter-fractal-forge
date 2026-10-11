# Backlog history

Historical records only. `goals.json` and `TODO.md` own current status and eligibility.

## Repository interview — 2026-10-11

The owner resolved the active-scope question and accepted the Android/web/Linux image-creation journey. Qualification remains planned. No implementation, publication, deployment, commit or dispatch occurred in this interview.

## Interview decisions completed

- [x] **DOC-PRD-001 — Reconcile current product-scope ownership.**
  - Goal: DOC-PRD-001. Payoff: separate current obligations from historical proposals without silently restoring MVP scope.
  - Sources: [Accepted release contract](PRD.md#active-release-contract), [Historical scope question](PRD.md#open-question-active-product-scope), [Resolved blocker](BLOCKERS.md), and `docs/planning/PRD.md`.
  - Graph evidence: partial local code-only export graph; product intent comes from explicit owner answers, not structural inference.
  - Scope: documentation and ledger only. Owner chose current backlog/README authority; conflicting old requirements remain historical/deferred. Explicit classifications are in PRD.md.
  - Acceptance: resolved BLK-20261005-004, consistent current/historical notices, preserved privacy and existing backlog classifications, and linked retained journey obligations to the three REL-JOURNEY tasks.
  - Dependencies: none.
  - Ownership: parent integration owner for this interview. No code changes, commit or dispatch.
  - Skill application: interview-me, explicit scope and outcome answers; documentation-and-adrs, existing owners and historical context; repo-docs, guarded integration and canonical ledger checks.

### Original decision task before the interview

Source: `TODO.md`, Needs decision. The following block is preserved verbatim as historical context. Its unchecked box and provisional default are not current task status; DOC-PRD-001 is complete in the canonical ledger.

- [ ] **DOC-PRD-001 — Reconcile current product-scope ownership.** Goal: resolve `BLK-20261005-004` and identify whether root `PRD.md` or the current backlog/README owns active scope where they differ. Default applied: treat conflicting, unimplemented root-PRD items as historical until revalidated; do not add product scope meanwhile. Scope: documentation and goal records only; no feature implementation. Acceptance: owner chooses A or B in `BLOCKERS.md`, then the PRD/backlog mark each affected item as active, deferred, or out of scope with consistent links. Source: [`PRD.md`](PRD.md), [`docs/planning/PRD.md`](docs/planning/PRD.md), and [`BLOCKERS.md`](BLOCKERS.md). Ownership: repository backlog.
  - Payoff: separate current obligations from historical proposals without silently expanding scope.
  - Scope-pending inventory: root PRD parameter locking, premultiplied-alpha UI toggle, five built-in presets per required fractal, startup shader compilation <200 ms, ten-minute animation memory stability, and remote analytics conflict. Planning PRD physical-device MediaStore/gallery and wallpaper checks, viewer-history integration, and human Spanish review lack explicit current qualification. Classify these with the scope decision before booking implementation.
  - Dependencies: none.
  - Ownership: product owner supplies the scope decision; repository backlog maintains documentation.
  - Check: accepted scope classification must link each retained obligation to a bounded implementation or verification task. Deferred or proposed work must not enter executable Now/Next.
  - Goal: DOC-PRD-001.
  - Scope: resolve root PRD versus backlog ownership and classify the scope-pending requirements above; no implementation.
  - Acceptance: record the owner’s A/B decision, classify affected requirements consistently, and link retained obligations to bounded checks or implementation tasks.
  - Sources: [Root PRD](PRD.md), [Historical readiness snapshot](docs/planning/PRD.md), and [Scope blocker](BLOCKERS.md).

Current release qualification is tracked by `REL-JOURNEY-001` in `goals.json`.
