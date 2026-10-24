+++
schema = 1
id = "CAT-QUALITY-01-LIVE"
title = "Live checks for CAT-QUALITY-01"
short = "Live checks for CAT-QUALITY-01"
status = "open"
goal = "CAT-QUALITY-001"
section = "Needs decision"
rank = 40000
depends_on = ["CAT-QUALITY-01"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for CAT-QUALITY-01 left pending."
acceptance = ["Each check passes on the real target: - Physical-device and human visual acceptance are not performed here. Repaired after-state comparisons, control exercise, named-target performance measurement, and edited-state PNG equivalence remain explicitly NOT_CHECKED for follow-up qualification; no artifacts or passes were fabricated."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#catalog-quality-and-variety); `todo.archive.md` retains the original offline task and evidence.
- Touches: none before conversion; ** stands for the whole repository
