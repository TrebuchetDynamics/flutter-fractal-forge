+++
schema = 1
id = "UI-OVERLAY-MIGRATION-03"
title = "Complete remaining plain-overlay migrations and harden short viewports"
short = "Complete remaining plain-overlay migr..."
status = "done"
section = "Now"
rank = 1000
depends_on = []
touches = ["lib/features/presets/preset_sheet.dart", "lib/features/viewer/export/viewer_export_overlay.dart", "lib/features/viewer/fractal_viewer_screen.dart", "lib/features/viewer/gaussian_moat_map.dart", "lib/features/viewer/diagnostics/viewer_debug_report.dart", "lib/features/catalog/fractal_catalog_screen.dart", "lib/features/catalog/widgets/catalog_widgets.dart", "lib/features/controls/widgets/number_wall_style_controls.dart", "lib/features/export/video_export_sheet.dart", "test/export/export_overlay_test.dart", "test/export/video_export_sheet_test.dart", "test/preset/preset_sheet_a11y_test.dart", "test/shared/app_sheet_components_test.dart", "test/features/controls/number_wall_color_dialog_test.dart", "test/a11y/screens/viewer_debug_report_a11y_test.dart"]
resources = []
kind = "implementation"
ownership = "coordinator"
scope = "Migrate remaining plain static sheet/dialog frames to existing shared owners; retain specialized sliver/tab/draggable/export controller ownership and audit their checks. Fix reproduced preset/progress overflow; preserve validation, callbacks and cancellation."
acceptance = ["Preset/share/text/Gaussian/catalog/debug/video plain sheets reuse AppSheetScaffold and showAppBottomSheet; RGB dialog reuses AppDialog with unchanged validation.", "Small landscape large-text progress/video overflow and preset viewport regressions fail before and pass after; cancellation, input validation, selection, link payload and text editor lifecycle tests pass.", "GPU debug report tests require pointer-reachable Report and an actually opened sheet at EN/ES and large text; toolbar overlap is fixed without changing toolbar ownership.", "Focused field and real pinned Cancel/Save buttons remain reachable above keyboard/navigation insets.", "Specialized export/history/wallpaper/palette/batch contracts are preserved and tested; independent review has no unresolved must-fix findings; omissions and device/full-gate limits are explicit."]
checks = ["Pinned Flutter focused shared, preset, share, export, Gaussian, catalog, text editor, history and wallpaper widget suites; changed-path analyzer and git diff --check."]
exclusions = ["No shader/math rewrites, new generic overlay manager, hidden/removal of user choices, publication or device qualification. Preserve existing dirty editor UI changes."]
closure = "manual"
closure_actor = "current Pi coordinator"
closure_timestamp = "2026-11-10T23:11:02.985068+00:00"
closure_reason = "Manual close: source commit 9436d5cd completes remaining plain-frame migrations and fixes reproduced progress/video overflow, preset viewport starvation and GPU Report toolbar overlap. Final no-retry focused run: 445 pass, no skips/missed-tap warnings; analyzer 15 paths clean; independent read-only review approved and reran 29 debug/RGB tests. Initial metadata load failures repaired by offline enforced-lockfile pub get (both locks unchanged); invalid RGB test fixture corrected with actual-input assertion. Specialized controller/job overlays retained and tested. Documentation impact limited to task receipt/comments. No full offline gate, device validation, push or publication claimed; prior editor changes excluded."
closure_evidence = "/tmp/architecture-review-20261110-ui-overlays-remaining.html"
+++
- Sources: Owner follow-up: Do remaining. Prior architecture report /tmp/architecture-review-20261110-ui-overlays.html; UI-OVERLAY-SHELL-INSETS-02 already landed.
