+++
schema = 1
id = "ACAD-015"
title = "Define quiet colour roles in dark and OLED themes and localize the auto-pilot crosshair label"
short = "Theme quiet roles + crosshair l10n"
status = "open"
section = "Next"
rank = 32000
depends_on = []
touches = ["lib/core/theme/app_theme.dart", "lib/l10n/", "lib/features/viewer/overlays/auto_pilot_alignment_overlay.dart", "test/features/viewer/auto_pilot_alignment_overlay_test.dart", "migration/"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "The dark and OLED colour schemes in lib/core/theme/app_theme.dart do not define onSurfaceVariant, outlineVariant, surfaceContainerHigh or surfaceContainerHighest, so Material falls back to pure white and to the surface colour (white shared-sheet dividers, no step for secondary text). Define these roles from the existing AppColors and OledColors values; leave the high-contrast theme unchanged. Add one l10n key for the auto-pilot crosshair semantics label (English text 'Auto-pilot paused. Align zoom with the center crosshair.' plus Spanish) and use it in AutoPilotAlignmentOverlay with the English fallback for hosts without localizations. Both edits change files bound by the migration provenance records (app_theme.dart and the generated app_localizations*.dart), so record the source transition under docs/tasks/source-bound-review-gates.md; do not refresh or strip hashes outside that process."
acceptance = ["Dark and OLED ColorScheme define onSurfaceVariant, outlineVariant, surfaceContainerHigh and surfaceContainerHighest; high contrast is unchanged", "AutoPilotAlignmentOverlay reads its semantics label from AppLocalizations and a Spanish widget test finds the Spanish label", "test/migration passes with a recorded provenance transition for the changed bound files", "Body and secondary text keep at least 4.5:1 contrast on the surface in dark and OLED themes"]
checks = ["flutter analyze", "flutter test"]
exclusions = []
+++
