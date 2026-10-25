+++
schema = 1
id = "QUAT-NORM-03-QUALIFY-LIVE"
title = "Live checks for QUAT-NORM-03-QUALIFY"
short = "Live checks for QUAT-NORM-03-QUALIFY"
status = "open"
goal = "QUAT-NORM-001"
section = "Next"
rank = 14000
depends_on = ["QUAT-NORM-03-QUALIFY"]
touches = ["docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for QUAT-NORM-03-QUALIFY left pending."
acceptance = ["Each check passes on the real target: - Android qualification remains pending until a named Android device is available; run the journey and verify decoded exported PNGs on that target. Linux evidence used Xvfb and is not a physical GPU qualification."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Accepted companion](PRD.md#prime-norm-quaternion-companion), [accepted slice design](docs/engineering/spec.md#prime-norm-quaternion-companion); parent qualification contract retained in `todo.archive.md`.
- Prior ownership: Await authorized live targets and human review; metadata repair grants neither.
- Held by: EVIDENCE-GATE: authorized Android target, decoded exported PNGs and remaining physical-GPU qualification
- Owner decision: 2026-10-25: Delegated by user to assistant. Authorize bounded local evidence preparation under the decision record and QUAL-EVIDENCE-01; retain all original human/device/source acceptance gates. No installs, production writes or transferred listener waiver. Decision resolved; remaining input: authorized Android target, decoded exported PNGs and remaining physical-GPU qualification. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until authorized Android target, decoded exported PNGs and remaining physical-GPU qualification. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
