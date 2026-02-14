<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# l10n

## Purpose
Generated localization files for EN and ES. Flutter's `gen-l10n` tool generates these from ARB files. Provides `AppLocalizations` class used throughout the app for translated strings.

## Key Files

| File | Description |
|------|-------------|
| `app_localizations.dart` | Generated base class with localization delegates and supported locales |
| `app_localizations_en.dart` | Generated English translations |
| `app_localizations_es.dart` | Generated Spanish translations |

## For AI Agents

### Working In This Directory
- These files are AUTO-GENERATED - do NOT edit them directly
- To add/modify translations: edit ARB files, then run `flutter gen-l10n`
- ARB source files are typically at project root or in a dedicated `l10n/` directory
- The `l10n.yaml` config at project root controls generation settings
- Access translations via `AppLocalizations.of(context)!.keyName`

### Common Patterns
- All user-visible strings should go through `AppLocalizations`
- Module display names use `ModuleNameBuilder` typedef: `(l10n) => l10n.moduleMandelbrot`
- Tooltip strings follow `tooltip*` naming convention

## Dependencies

### Internal
- `l10n.yaml` (project root) - Generation configuration
- ARB source files - Translation source data

### External
- `flutter_localizations` SDK - i18n framework
- `intl` - Internationalization utilities

<!-- MANUAL: -->
