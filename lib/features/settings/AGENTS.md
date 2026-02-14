<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# settings

## Purpose
Accessibility settings screen for configuring visual and interaction preferences.

## Key Files

| File | Description |
|------|-------------|
| `accessibility_settings_screen.dart` | `AccessibilitySettingsScreen` - toggles for high contrast, reduced motion, large text, and other accessibility options |

## For AI Agents

### Working In This Directory
- Settings modify `AccessibilityService` (ChangeNotifier)
- High contrast toggle switches between `AppTheme.dark` and `AppTheme.highContrast`
- Changes persist via SharedPreferences through AccessibilityService

## Dependencies

### Internal
- `core/services/accessibility_service.dart` - Settings state
- `core/theme/app_theme.dart` - Theme variants

<!-- MANUAL: -->
