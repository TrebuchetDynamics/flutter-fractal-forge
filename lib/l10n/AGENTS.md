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

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions before implementing; ask when uncertainty would change the solution.
- Surface multiple interpretations and tradeoffs instead of silently picking one.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/l10n`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->
