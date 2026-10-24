+++
schema = 1
id = "SMOOTH-001-INVENTORY-02-LIVE"
title = "Live checks for SMOOTH-001-INVENTORY-02"
short = "Live checks for SMOOTH-001-INVENTORY-02"
status = "open"
goal = "GOAL-SMOOTH-001"
section = "Needs decision"
rank = 39000
depends_on = ["SMOOTH-001-INVENTORY-02"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for SMOOTH-001-INVENTORY-02 left pending."
acceptance = ["Each check passes on the real target: - Visual or hardware-GPU qualification for the checked Multibrot shaders was not run; source and numeric fixtures are offline evidence only."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](TODO.md#p1-3-smooth-coloring-in-all-shaders); `todo.archive.md` retains the original offline task and evidence.
- Touches: none before conversion; ** stands for the whole repository
