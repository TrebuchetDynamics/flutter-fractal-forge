import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding completion state.
///
/// Persists whether the user has completed the onboarding flow
/// using SharedPreferences.
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _onboardingVersionKey = 'onboarding_version';

  /// Current onboarding version. Increment to show onboarding again
  /// after significant app updates.
  static const int currentVersion = 1;

  final SharedPreferences _prefs;

  OnboardingService._(this._prefs);

  /// Creates a new [OnboardingService] instance.
  static Future<OnboardingService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingService._(prefs);
  }

  /// Creates an [OnboardingService] with an existing [SharedPreferences] instance.
  factory OnboardingService.withPrefs(SharedPreferences prefs) {
    return OnboardingService._(prefs);
  }

  /// Returns true if onboarding has been completed for the current version.
  bool get isOnboardingComplete {
    final complete = _prefs.getBool(_onboardingCompleteKey) ?? false;
    final version = _prefs.getInt(_onboardingVersionKey) ?? 0;
    return complete && version >= currentVersion;
  }

  /// Marks onboarding as complete for the current version.
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
    await _prefs.setInt(_onboardingVersionKey, currentVersion);
  }

  /// Resets onboarding state (useful for testing or user preference).
  Future<void> resetOnboarding() async {
    await _prefs.remove(_onboardingCompleteKey);
    await _prefs.remove(_onboardingVersionKey);
  }
}
