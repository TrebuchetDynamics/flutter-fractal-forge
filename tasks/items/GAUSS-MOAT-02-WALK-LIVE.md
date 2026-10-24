+++
schema = 1
id = "GAUSS-MOAT-02-WALK-LIVE"
title = "Live checks for GAUSS-MOAT-02-WALK"
short = "Live checks for GAUSS-MOAT-02-WALK"
status = "open"
goal = "GAUSS-MOAT-001"
section = "Needs decision"
rank = 32000
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
- Owner decision: 2026-10-16 — Defer until a suitable physical device and reviewer are available; preserve visual, accessibility and performance gates. Deferral is neither completion nor a release waiver.
- Next action: Keep this live task open in Needs decision. Resume qualification planning when actual device/reviewer access exists; retain original physical-device acceptance rather than substituting offline model tests.
- Touches: none before conversion; ** stands for the whole repository
