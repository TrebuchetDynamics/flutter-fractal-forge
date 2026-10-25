+++
schema = 1
id = "QUAT-NORM-02-WALK-LIVE"
title = "Live checks for QUAT-NORM-02-WALK"
short = "Live checks for QUAT-NORM-02-WALK"
status = "open"
goal = "QUAT-NORM-001"
section = "Next"
rank = 13000
depends_on = ["QUAT-NORM-02-WALK"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for QUAT-NORM-02-WALK left pending."
acceptance = ["Each check passes on the real target: - Physical-device gesture/accessibility/native export qualification remains unrun."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing accepted companion contract](PRD.md#prime-norm-quaternion-companion); `todo.archive.md` retains the original offline task and evidence.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: physical-device gesture/accessibility/native-export qualification
- Owner decision: 2026-10-25: Delegated by user to assistant. Authorize bounded local evidence preparation under the decision record and QUAL-EVIDENCE-01; retain all original human/device/source acceptance gates. No installs, production writes or transferred listener waiver. Decision resolved; remaining input: physical-device gesture/accessibility/native-export qualification. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until physical-device gesture/accessibility/native-export qualification. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
