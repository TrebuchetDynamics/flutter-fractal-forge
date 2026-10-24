+++
schema = 1
id = "REL-JOURNEY-03-ANDROID-LIVE"
title = "Live checks for REL-JOURNEY-03-ANDROID"
short = "Live checks for REL-JOURNEY-03-ANDROID"
status = "open"
goal = "REL-JOURNEY-001"
section = "Needs decision"
rank = 37000
depends_on = ["REL-JOURNEY-03-ANDROID"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Run the live checks the offline work for REL-JOURNEY-03-ANDROID left pending."
acceptance = ["Each check passes on the real target: - Connect a named Android device and run the shared edited Mandelbrot/Mandelbulb image-creation journey. - Add or confirm a platform-specific journey target that reads back and decodes the actual MediaStore PNGs and verifies gallery visibility; current shared journey checks its app export file only and does not verify MediaStore/gallery state. - Record each saved image's selected dimensions, readable PNG content, edited viewer state, device ID, backend and exact command. Keep emulator evidence separate from physical-device qualification."]
checks = ["Live qualification by an authorized person; offline evidence does not count."]
exclusions = []
+++

- Sources: [Existing goal contract](PRD.md#active-release-contract); `todo.archive.md` retains the original offline task and evidence.
- Owner decision: 2026-10-16 — Defer until a named Android test device is available; retain gallery/MediaStore and PNG-readback requirements. Deferral is neither completion nor a release waiver.
- Next action: Keep this live task open in Needs decision. When a named device is available, verify the actual edited Mandelbrot/Mandelbulb MediaStore/gallery outputs, decode PNGs, and record dimensions/content, device/backend and exact commands. Keep physical-device and emulator verdicts distinct.
- Touches: none before conversion; ** stands for the whole repository
