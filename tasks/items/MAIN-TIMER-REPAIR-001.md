+++
schema = 1
id = "MAIN-TIMER-REPAIR-001"
title = "Repair main-check timer synchronization regressions"
short = "Restore timer regression gates"
status = "open"
goal = "APP-QUALITY-001"
section = "Now"
rank = 1000
depends_on = []
touches = ["test/features/auto_explore/auto_explore_service_test.dart", "test/features/viewer/actions/viewer_music_coordinator_test.dart", "lib/features/auto_explore/auto_explore_service.dart"]
resources = []
kind = "implementation"
ownership = "coordinator"
scope = "Repair the three main-check timer regressions observed on 8d841916: module-switch auto-explore direction and music refresh after startup/restart. Use observable completion or controlled time, not longer sleeps or relaxed assertions. A test-first stale completed-leg continuation reproduction justifies a motion generation guard. Interactive queue-recovery session owns the uncommitted reviewed candidate; full offline gate and integration remain pending."
acceptance = ["Both affected test files pass with strict direction/playback assertions and bounded cleanup; startup refresh must occur before the configured loop delay; production cancellation repair has red/green coverage."]
checks = ["flutter pub get --offline --enforce-lockfile", "flutter test --no-pub test/features/auto_explore/auto_explore_service_test.dart test/features/viewer/actions/viewer_music_coordinator_test.dart --reporter expanded", "Format changed Dart files, focused analysis, git diff --check; full offline gate before integration."]
exclusions = ["No release, registry, dependencies, lifecycle feature, service control, runtime gate changes, publication, or other workers edits. Preserve APP-003-f7 lifecycle scope and serialize overlapping changes."]
+++
- Held by: Preserved uncommitted queue-recovery candidate in canonical working tree; not a live worker claim. Pending full offline gate and local commit/integration; do not duplicate implementation.
- Checks status: Focused Linux-host validation with pinned Flutter 3.44.6: offline lockfile-enforced preparation passed with unchanged lockfile; 39 tests in the two affected files passed; targeted analysis, formatting and diff check passed. Independent review found a startup-delay oracle gap, corrected by placing the loop delay beyond the bounded polling timeout. Full offline gate and integration are NOT_CHECKED; no commit or publication.
