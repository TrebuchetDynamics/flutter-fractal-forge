+++
schema = 1
id = "RELEASE-001-23-LIVE"
title = "Live checks for RELEASE-001-23"
short = "Live checks for RELEASE-001-23"
status = "open"
goal = "REL-JOURNEY-001"
section = "Next"
rank = 17000
depends_on = ["RELEASE-001-23"]
touches = ["docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for RELEASE-001-23 left pending."
acceptance = ["Each check passes on the real target: - Run the actual Linux native edited-view and decoded-PNG journey on a supported Linux target; the offline test used controlled subprocess doubles. - Qualify Windows, macOS and iOS journey/export gates on their supported hosts; until lane-local receipts exist those lanes remain unknown and are not publishable. - On authorized targets, validate real Android device qualification, Play remote bundle/track readback, Cloudflare deployment asset readback and GitHub asset download readback. No live service or signing operation was performed. - Complete external F-Droid acceptance and Apple signing/store qualification where applicable."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign); parent contract retained in `todo.archive.md`.
- Prior ownership: Await authorized targets and separately scoped live-operation approval; metadata repair grants neither.
- Planning handoff: 2026-10-23 lane map and recovery plan: PRD.md#release-continuation-plan--2026-10-23. Reuse this existing live-proof owner for Windows, macOS, iOS and F-Droid requirements; absent native hosts, signing, approved Apple publication route or external F-Droid acceptance remain explicit lane-local gaps. No new access, host purchase or live authority is granted.
- Held by: EVIDENCE-GATE: missing lane hosts and target verdicts; signing, credentialed remote operations and external Apple/F-Droid acceptance remain separately gated
- Owner decision: 2026-10-25: Delegated by user to assistant. Authorize local lane evidence preparation only on existing permitted hosts; no remote credentialed readback, signing or external publication/acceptance authority. Decision resolved; remaining input: missing lane hosts and target verdicts; signing, credentialed remote operations and external Apple/F-Droid acceptance remain separately gated. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until missing lane hosts and target verdicts; signing, credentialed remote operations and external Apple/F-Droid acceptance remain separately gated. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
