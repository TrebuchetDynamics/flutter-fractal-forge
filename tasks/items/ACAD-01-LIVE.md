+++
schema = 1
id = "ACAD-01-LIVE"
title = "Live checks for ACAD-01"
short = "Live checks for ACAD-01"
status = "open"
goal = "ACAD-001"
section = "Next"
rank = 1000
depends_on = ["ACAD-01"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for ACAD-01 left pending."
acceptance = ["Each check passes on the real target: - Human adjudication of title-collision suggestions and identity aliases remains pending; unresolved identities intentionally stay coverage gaps."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#academic-research-library); `todo.archive.md` retains the original offline task and evidence.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: attributable human identity/alias adjudication after the draft packet
- Owner decision: 2026-10-25: Delegated by user to assistant. Prepare agent-draft collision/alias recommendations under ACAD-DRAFT-01; human adjudication remains required. Decision resolved; remaining input: attributable human identity/alias adjudication after the draft packet. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until attributable human identity/alias adjudication after the draft packet. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
