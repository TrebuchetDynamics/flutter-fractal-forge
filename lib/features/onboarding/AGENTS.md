<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# onboarding

## Purpose
First-launch onboarding flow introducing users to the app's features and gestures.

## Key Files

| File | Description |
|------|-------------|
| `onboarding_screen.dart` | `OnboardingScreen` - multi-page onboarding carousel with gesture tutorials |

## For AI Agents

### Working In This Directory
- Shown only on first launch (tracked by `OnboardingService`)
- Calls `onComplete` callback when finished to transition to HomeScreen

### Testing Requirements
- `test/onboarding_screen_widget_test.dart`

## Dependencies

### Internal
- `core/services/onboarding_service.dart` - Completion state tracking

<!-- MANUAL: -->
