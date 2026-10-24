+++
schema = 1
id = "APP-004-cc"
title = "Localize settings and export controls with selected semantics.**"
short = "Localize settings and export controls with selected semantics.**"
status = "open"
goal = "APP-QUALITY-001"
section = "Next"
rank = 9000
depends_on = ["APP-002-e0", "FIB-PRIME-02"]
touches = ["lib/features/settings/settings_screen.dart", "lib/features/export/export_options_sheet.dart", "lib/l10n/", "test/screens/settings_screen_a11y_test.dart", "test/export/export_options_sheet_widget_test.dart", "test/features/export/custom_export_dimensions_test.dart"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Use existing EN/ES localization at UI boundaries for theme names/descriptions and actual export resolution labels. Give each theme option a single accessible activation/focus node and selected state. Preserve enum/persistence values, custom export dimensions/validation, existing typography/theme/chip/sheet patterns and export data. No theme redesign or unused video UI work."
acceptance = ["Spanish theme sheet contains localized titles/descriptions and one selected action node per option; EN copy remains coherent. Keyboard activation changes the theme once and reopening preserves selection. Both actual export-sheet locales show localized resolution choices with unchanged selected resolution/dimensions, submission and invalid-custom-size rejection. Existing narrow/large-text/high-contrast guards pass; no duplicate semantic action stops or storage-key changes."]
checks = ["`flutter gen-l10n`; `flutter test test/screens/settings_screen_a11y_test.dart test/export/export_options_sheet_widget_test.dart test/features/export/custom_export_dimensions_test.dart test/export/viewer_export_session_test.dart --reporter expanded`; `dart format --output=none --set-exit-if-changed lib/features/settings/settings_screen.dart lib/features/export/export_options_sheet.dart test/screens/settings_screen_a11y_test.dart test/export/export_options_sheet_widget_test.dart test/features/export/custom_export_dimensions_test.dart`; `flutter analyze`; `git diff --check`. Locale/semantics fixture extensions are planned."]
exclusions = []
+++

- Section: Next.
- Sources: [Accepted bounded plan](docs/engineering/spec.md#mcp-assisted-app-quality), [owner outcome](PRD.md#mcp-assisted-architecture-and-ui-improvement), [verification](docs/engineering/test-plan.md#mcp-assisted-app-quality-verification), [MCP workflow](docs/engineering/runbook.md#official-dart-flutter-mcp-workflow).
- Ownership: Repository backlog, unassigned; preserve current writers and source-bound evidence. Planning does not dispatch.
- Next action: Extend the existing Spanish settings test to open the theme sheet and parameterize the existing export-sheet harness locale; localize only actual UI labels and add selected semantics without changing serialized enums.
- Overlap resolution: DOCS-MAINTAINER: serialize after FIB-PRIME-02 while retaining APP-002-e0. FIB-PRIME-02 attempt-1 is running (slot-data/FIB-PRIME-02/attempt-1/meta.json and slots/FIB-PRIME-02.json under .git/autowork-execution; no final report yet). Its current candidate changes test/screens/settings_screen_a11y_test.dart for the catalog count and lib/l10n/app_en.arb, lib/l10n/app_es.arb and generated localizations for the module legend/counts, as required by docs/engineering/spec.md#fibonacci-prime-degree-julia. APP-004-cc has no execution slot. Merging into a running task is excluded; splitting settings from export would still share the EN/ES localization files because both UI boundaries require localized copy under docs/engineering/spec.md#mcp-assisted-app-quality. Keep all APP-004-cc scope, acceptance, checks, touches and queue position; after the prerequisite lands, extend the integrated fixtures without reverting its count or Fibonacci labels.
