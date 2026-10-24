+++
schema = 1
id = "VIEW-UI-02-LIVE"
title = "Live checks for VIEW-UI-02"
short = "Live checks for VIEW-UI-02"
status = "open"
goal = "VIEW-UI-001"
section = "Needs decision"
rank = 31000
depends_on = ["VIEW-UI-02"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for VIEW-UI-02 left pending."
acceptance = ["Each check passes on the real target: - Same-state native screenshots, production typography validation, and physical-device/screen-reader acceptance remain outstanding. Flutter 3.44.6 qualification was not run; this environment provides Flutter 3.44.2."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency); `todo.archive.md` retains the original offline task and evidence.
- Owner decision: 2026-10-16 — Defer until target/reviewer access is available; preserve native screenshots, typography and screen-reader checks. Deferral is neither completion nor a release waiver.
- Next action: Keep this live task open in Needs decision. When target/reviewer access exists, reconcile exact SDK receipts and complete the retained real-target acceptance; historical environment wording is not proof of current SDK absence.
- Touches: none before conversion; ** stands for the whole repository
