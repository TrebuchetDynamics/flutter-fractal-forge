+++
schema = 1
id = "SMOOTH-001-INVENTORY-01-LIVE"
title = "Live checks for SMOOTH-001-INVENTORY-01"
short = "Live checks for SMOOTH-001-INVENTORY-01"
status = "open"
goal = "GOAL-SMOOTH-001"
section = "Needs decision"
rank = 36000
depends_on = ["SMOOTH-001-INVENTORY-01"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for SMOOTH-001-INVENTORY-01 left pending."
acceptance = ["Each check passes on the real target: - Hardware-GPU visual qualification was not run; the source-level checks do not establish rendered appearance or performance."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](TODO.md#p1-3-smooth-coloring-in-all-shaders); `todo.archive.md` retains the original offline task and evidence.
- Owner decision: 2026-10-16 — Defer hardware-GPU qualification; retain source-test evidence without calling it visual proof. Deferral is neither completion nor a release waiver.
- Next action: Keep this live task open in Needs decision until a named hardware-GPU qualification session is planned; preserve its actual-rendering and performance requirements without reclassifying source assertions as rendered evidence.
- Touches: none before conversion; ** stands for the whole repository
