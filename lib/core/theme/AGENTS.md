<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# theme

## Purpose
Application theming with dark and high-contrast theme variants. Defines colors, text styles, and Material theme data used throughout the app.

## Key Files

| File | Description |
|------|-------------|
| `app_theme.dart` | `AppTheme` class with static `dark` and `highContrast` ThemeData. `AppColors` constants for background, surface, accent colors |

## For AI Agents

### Working In This Directory
- Two themes: `AppTheme.dark` (default) and `AppTheme.highContrast` (accessibility)
- Theme selection controlled by `AccessibilityService.highContrastEnabled`
- `AppColors.background` used for system navigation bar color
- Dark purple/space theme aesthetic throughout

## Dependencies

### Internal
- Consumed by `main.dart` and all feature screens

<!-- MANUAL: -->
