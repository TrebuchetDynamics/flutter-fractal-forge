+++
schema = 1
id = "QUAT-NORM-03-QUALIFY-LIVE"
title = "Live checks for QUAT-NORM-03-QUALIFY"
short = "Live checks for QUAT-NORM-03-QUALIFY"
status = "open"
goal = "QUAT-NORM-001"
section = "Needs decision"
rank = 46000
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
- Ownership: Await authorized live targets and human review; metadata repair grants neither.
