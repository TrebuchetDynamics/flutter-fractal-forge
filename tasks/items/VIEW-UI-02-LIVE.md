+++
schema = 1
id = "VIEW-UI-02-LIVE"
title = "Live checks for VIEW-UI-02"
short = "Live checks for VIEW-UI-02"
status = "open"
goal = "VIEW-UI-001"
section = "Next"
rank = 22000
depends_on = ["VIEW-UI-02"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for VIEW-UI-02 left pending."
acceptance = ["Each check passes on the real target: - Same-state native screenshots, production typography validation, and physical-device/screen-reader acceptance remain outstanding. Flutter 3.44.6 qualification was not run; this environment provides Flutter 3.44.2."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency); `todo.archive.md` retains the original offline task and evidence.
- Prior owner decision: 2026-10-16 — Defer until target/reviewer access is available; preserve native screenshots, typography and screen-reader checks. Deferral is neither completion nor a release waiver.
- Prior next action: Keep this live task open in Needs decision. When target/reviewer access exists, reconcile exact SDK receipts and complete the retained real-target acceptance; historical environment wording is not proof of current SDK absence.
- Touches: none before conversion; ** stands for the whole repository
- Held by: EVIDENCE-GATE: actual native screenshots/SDK/typography plus physical screen-reader reviewer verdict
- Owner decision: 2026-10-25: Delegated by user to assistant. Authorize bounded local evidence preparation under the decision record and QUAL-EVIDENCE-01; retain all original human/device/source acceptance gates. No installs, production writes or transferred listener waiver. Decision resolved; remaining input: actual native screenshots/SDK/typography plus physical screen-reader reviewer verdict. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until actual native screenshots/SDK/typography plus physical screen-reader reviewer verdict. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
