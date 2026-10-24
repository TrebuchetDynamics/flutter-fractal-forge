+++
schema = 1
id = "QUAT-NORM-02-WALK-LIVE"
title = "Live checks for QUAT-NORM-02-WALK"
short = "Live checks for QUAT-NORM-02-WALK"
status = "open"
goal = "QUAT-NORM-001"
section = "Needs decision"
rank = 43000
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
