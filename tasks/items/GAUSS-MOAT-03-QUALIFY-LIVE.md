+++
schema = 1
id = "GAUSS-MOAT-03-QUALIFY-LIVE"
title = "Live checks for GAUSS-MOAT-03-QUALIFY"
short = "Live checks for GAUSS-MOAT-03-QUALIFY"
status = "open"
goal = "GAUSS-MOAT-001"
section = "Needs decision"
rank = 49000
depends_on = ["GAUSS-MOAT-03-QUALIFY"]
touches = ["docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for GAUSS-MOAT-03-QUALIFY left pending."
acceptance = ["Each check passes on the real target: - Android journey has not run on a named device; decode its selected-dimension PNG and verify actual MediaStore/gallery persistence/readability. Keep emulator and physical-device evidence separate. - B=128 cap/chunk/job/cancellation telemetry and real target-specific timing/memory remain unmeasured. Xvfb and the single B=32 Chromium observation do not establish physical GPU or cross-target performance. - Complete live EN/ES, responsive, keyboard/focus and screen-reader qualification on the named platforms, plus human review of exported mathematical composition, remains pending."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Accepted scope](PRD.md#gaussian-moat-walking-visualization), [bounded design](docs/engineering/spec.md#gaussian-moat-walking-visualization); parent qualification contract retained in `todo.archive.md`.
- Ownership: Await authorized live targets and human review; metadata repair grants neither.
