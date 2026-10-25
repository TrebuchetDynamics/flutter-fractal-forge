+++
schema = 1
id = "GAUSS-MOAT-02-WALK-LIVE"
title = "Live checks for GAUSS-MOAT-02-WALK"
short = "Live checks for GAUSS-MOAT-02-WALK"
status = "open"
goal = "GAUSS-MOAT-001"
section = "Next"
rank = 8000
depends_on = ["GAUSS-MOAT-02-WALK"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for GAUSS-MOAT-02-WALK left pending."
acceptance = ["Each check passes on the real target: - Physical-device visual, accessibility, and performance qualification."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#gaussian-moat-walking-visualization); `todo.archive.md` retains the original offline task and evidence.
- Prior owner decision: 2026-10-16 — Defer until a suitable physical device and reviewer are available; preserve visual, accessibility and performance gates. Deferral is neither completion nor a release waiver.
- Prior next action: Keep this live task open in Needs decision. Resume qualification planning when actual device/reviewer access exists; retain original physical-device acceptance rather than substituting offline model tests.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: suitable named physical device and visual/accessibility/performance reviewer
- Owner decision: 2026-10-25: Delegated by user to assistant. Authorize bounded local evidence preparation under the decision record and QUAL-EVIDENCE-01; retain all original human/device/source acceptance gates. No installs, production writes or transferred listener waiver. Decision resolved; remaining input: suitable named physical device and visual/accessibility/performance reviewer. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until suitable named physical device and visual/accessibility/performance reviewer. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
