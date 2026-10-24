+++
schema = 1
id = "GAUSS-MOAT-04-GROWTH-LIVE"
title = "Live checks for GAUSS-MOAT-04-GROWTH"
short = "Live checks for GAUSS-MOAT-04-GROWTH"
status = "open"
goal = "GAUSS-MOAT-001"
section = "Needs decision"
rank = 48000
depends_on = ["GAUSS-MOAT-04-GROWTH"]
touches = ["docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for GAUSS-MOAT-04-GROWTH left pending."
acceptance = ["Each check passes on the real target: - GAUSS-MOAT-03-QUALIFY real journey and live/device qualification remain separate pending gates; offline capture tests are not live qualification."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Accepted growth plan](docs/engineering/spec.md#gaussian-moat-walking-visualization), [growth details](docs/engineering/spec.md#bounded-radius-growth-and-visual-direction); parent contract retained in `todo.archive.md`.
- Ownership: Await authorized live targets and human review; metadata repair grants neither.
