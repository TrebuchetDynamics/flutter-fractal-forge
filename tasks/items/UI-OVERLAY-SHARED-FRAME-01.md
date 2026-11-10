+++
schema = 1
id = "UI-OVERLAY-SHARED-FRAME-01"
title = "Unify modal sheet frames and keep large-text headers scrollable"
short = "Unify modal sheet frames and keep lar..."
status = "done"
section = "Now"
rank = 7000
depends_on = []
touches = ["lib/shared/widgets/app_bottom_sheet.dart", "lib/shared/widgets/app_sheet_scaffold.dart", "lib/features/settings/settings_screen.dart", "lib/features/debug/log_viewer_screen.dart", "lib/features/viewer/fractal_viewer_screen.dart", "test/shared/app_sheet_components_test.dart"]
resources = []
kind = "implementation"
ownership = "coordinator"
scope = "Shared modal sheet frame, options adapter, theme selector and log export; preserve specialized renderer, draggable/sliver and export lifecycles."
acceptance = ["AppOptionsSheet and AppSheetScaffold share one layout implementation while retaining import compatibility and footer actions.", "Short landscape at 3x text keeps header, body and close reachable without RenderFlex overflow; navigation and keyboard insets remain reserved.", "Theme selector and log export reuse the shared frame; focused shared and affected feature tests pass and independent review has no unresolved must-fix findings."]
checks = ["Pinned Flutter: flutter test --no-pub test/shared/ test/screens/settings_screen_a11y_test.dart test/diagnostics/log_viewer_screen_test.dart test/a11y/screens/looper_sheet_a11y_test.dart test/fractal/viewer_toolbar_layout_test.dart test/fractal/fractal_view_controls_test.dart", "Pinned Flutter: flutter analyze --no-pub on changed Dart paths; git diff --check"]
exclusions = ["No shader/domain changes, generic overlay manager, publication, device claims, or editor redesign changes."]
closure = "manual"
closure_actor = "current Pi coordinator"
closure_timestamp = "2026-11-10T05:59:06.206102+00:00"
closure_reason = "Manual close after source fix df9009e7, reproduced-before/passing-after overflow regressions, 262 focused tests and 35 additional tests passing, scoped analyzer clean and independent read-only review approved. No claim of automated Verified receipt or device/full-offline qualification. Prior editor changes remain uncommitted and excluded."
closure_evidence = "/tmp/architecture-review-20261110-ui-overlays.html"
+++
- Sources: Owner request in current session: refactor UI overlays, fix issues and share code.
