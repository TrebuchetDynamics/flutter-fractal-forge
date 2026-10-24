+++
schema = 1
id = "VIEW-UI-01-LIVE"
title = "Live checks for VIEW-UI-01"
short = "Live checks for VIEW-UI-01"
status = "open"
goal = "VIEW-UI-001"
section = "Needs decision"
rank = 30000
depends_on = ["VIEW-UI-01"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for VIEW-UI-01 left pending."
acceptance = ["Each check passes on the real target: - Physical-device screen-reader/TalkBack/VoiceOver and device-rotation qualification. - Hardware-GPU and bundled production-font qualification; the Linux/Xvfb run uses software llvmpipe/native font fallback."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency); `todo.archive.md` retains the original offline task and evidence.
- Owner decision: 2026-10-16 — Defer until a suitable test device and reviewer are available; preserve every acceptance check. Deferral is neither completion nor a release waiver.
- Next action: Keep this live task open in Needs decision. Resume qualification planning when suitable target/reviewer access exists; retain screen-reader, rotation, hardware-GPU and production-font checks. Do not substitute offline results for real-target evidence.
- Touches: none before conversion; ** stands for the whole repository
