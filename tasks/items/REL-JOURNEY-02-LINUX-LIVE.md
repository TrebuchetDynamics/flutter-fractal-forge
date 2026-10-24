+++
schema = 1
id = "REL-JOURNEY-02-LINUX-LIVE"
title = "Live checks for REL-JOURNEY-02-LINUX"
short = "Live checks for REL-JOURNEY-02-LINUX"
status = "open"
goal = "REL-JOURNEY-001"
section = "Needs decision"
rank = 34000
depends_on = ["REL-JOURNEY-02-LINUX"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for REL-JOURNEY-02-LINUX left pending."
acceptance = ["Each check passes on the real target: - Human visual review of exported image composition/readability; the integration test deletes its temporary PNGs after numerical checks."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#active-release-contract); `todo.archive.md` retains the original offline task and evidence.
- Owner decision: 2026-10-16 — Have the runner prepare retained real-export images for human review; keep visual acceptance pending. This does not approve unseen output or waive real-target checks.
- Next action: Prepare representative real edited-state Linux PNG exports using the existing journey path, retain the actual files and provenance instead of only deleted temporary artifacts, and present them for composition/readability review. Keep this task open until an attributable human verdict; do not fabricate images or infer visual acceptance from numerical PNG checks.
- Touches: none before conversion; ** stands for the whole repository
- Planning handoff: 2026-10-23 release continuation: PRD.md#release-continuation-plan--2026-10-23. Existing retained actual Mandelbrot/Mandelbulb PNGs and state sidecars in the prior release evidence may support historical review only when source/backend/state match. Keep edited-view equivalence, EN/ES/inspired coverage and attributable human verdict open; current main or another source needs its own qualification. No visual approval is inferred.
