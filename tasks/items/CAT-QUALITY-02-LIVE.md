+++
schema = 1
id = "CAT-QUALITY-02-LIVE"
title = "Live checks for CAT-QUALITY-02"
short = "Live checks for CAT-QUALITY-02"
status = "open"
goal = "CAT-QUALITY-001"
section = "Needs decision"
rank = 45000
depends_on = ["CAT-QUALITY-02"]
touches = ["docs/planning/visual-fidelity-audit-next.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for CAT-QUALITY-02 left pending."
acceptance = ["Each check passes on the real target: - Physical/mobile platform and applicable REL-JOURNEY edited-save/share/readback qualification remain unrun; host AMD Linux captures are not cross-platform qualification. - No independent registered reference oracle exists for these three formulas; no mathematical certification or human formula review is claimed."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety); original offline contract retained under CAT-QUALITY-02 in `todo.archive.md`.
- Ownership: Await authorized live-target access and human review; this metadata repair grants neither.
