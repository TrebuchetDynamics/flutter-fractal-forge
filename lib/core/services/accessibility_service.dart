import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing accessibility settings across the app.
///
/// Provides:
/// - High contrast mode for users with low vision
/// - Reduced motion mode for users with vestibular disorders
/// - Screen reader announcements helper
/// - Large text support detection
///
/// Settings are persisted to SharedPreferences and restored on app launch.
///
/// {@category Accessibility}
///
/// Example usage:
/// ```dart
/// final accessibility = AccessibilityService(prefs);
///
/// // Check if high contrast mode is enabled
/// if (accessibility.highContrastEnabled) {
///   // Use high contrast colors
/// }
///
/// // Announce to screen readers
/// accessibility.announce('Fractal loaded');
/// ```
class AccessibilityService extends ChangeNotifier {
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyReducedMotion = 'accessibility_reduced_motion';
  static const String _keyLargeTargets = 'accessibility_large_targets';

  final SharedPreferences _prefs;

  bool _highContrastEnabled;
  bool _reducedMotionEnabled;
  bool _largeTargetsEnabled;

  /// Creates an [AccessibilityService] with the given [SharedPreferences].
  AccessibilityService(this._prefs)
      : _highContrastEnabled = _prefs.getBool(_keyHighContrast) ?? false,
        _reducedMotionEnabled = _prefs.getBool(_keyReducedMotion) ?? false,
        _largeTargetsEnabled = _prefs.getBool(_keyLargeTargets) ?? false;

  /// Creates an instance asynchronously by loading SharedPreferences.
  static Future<AccessibilityService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AccessibilityService(prefs);
  }

  /// Whether high contrast mode is enabled.
  ///
  /// When true, the app should use higher contrast colors
  /// with more distinct borders and larger text.
  bool get highContrastEnabled => _highContrastEnabled;

  /// Whether reduced motion mode is enabled.
  ///
  /// When true, animations should be minimized or disabled
  /// to help users with vestibular disorders.
  bool get reducedMotionEnabled => _reducedMotionEnabled;

  /// Whether large touch targets are enabled.
  ///
  /// When true, interactive elements should have larger hit areas
  /// (minimum 48x48 logical pixels per WCAG guidelines).
  bool get largeTargetsEnabled => _largeTargetsEnabled;

  /// Enables or disables high contrast mode.
  Future<void> setHighContrast(bool enabled) async {
    if (_highContrastEnabled == enabled) return;
    _highContrastEnabled = enabled;
    await _prefs.setBool(_keyHighContrast, enabled);
    notifyListeners();
  }

  /// Enables or disables reduced motion mode.
  Future<void> setReducedMotion(bool enabled) async {
    if (_reducedMotionEnabled == enabled) return;
    _reducedMotionEnabled = enabled;
    await _prefs.setBool(_keyReducedMotion, enabled);
    notifyListeners();
  }

  /// Enables or disables large touch targets.
  Future<void> setLargeTargets(bool enabled) async {
    if (_largeTargetsEnabled == enabled) return;
    _largeTargetsEnabled = enabled;
    await _prefs.setBool(_keyLargeTargets, enabled);
    notifyListeners();
  }

  /// Announces a message to screen readers.
  ///
  /// Uses [SemanticsService] to make the message
  /// audible to TalkBack/VoiceOver users.
  ///
  /// [politeness] controls interruption behavior:
  /// - [Assertiveness.polite]: Waits for current speech to finish
  /// - [Assertiveness.assertive]: Interrupts current speech (use sparingly)
  static void announce(
    String message, {
    Assertiveness politeness = Assertiveness.polite,
  }) {
    // ignore: deprecated_member_use
    SemanticsService.announce(message, TextDirection.ltr, assertiveness: politeness);
  }

  /// Checks if the system has accessibility features enabled.
  ///
  /// Returns true if any of these are active:
  /// - Screen reader (TalkBack/VoiceOver)
  /// - Reduce motion preference
  /// - Bold text preference
  /// - High contrast preference
  static bool isSystemAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation ||
        mediaQuery.disableAnimations ||
        mediaQuery.boldText ||
        mediaQuery.highContrast;
  }

  /// Checks if the system prefers reduced motion.
  ///
  /// This checks the OS-level "Reduce Motion" setting.
  static bool systemPrefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Checks if a screen reader is active.
  ///
  /// Returns true when TalkBack (Android) or VoiceOver (iOS) is running.
  static bool isScreenReaderActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Returns the appropriate animation duration based on settings.
  ///
  /// If reduced motion is enabled (either in-app or system-level),
  /// returns [Duration.zero] to disable animations.
  Duration getAnimationDuration(BuildContext context, Duration normalDuration) {
    if (_reducedMotionEnabled || systemPrefersReducedMotion(context)) {
      return Duration.zero;
    }
    return normalDuration;
  }
}

/// Extension to check accessibility preferences from BuildContext.
extension AccessibilityContext on BuildContext {
  /// Whether animations should be reduced based on user/system preferences.
  bool get shouldReduceMotion {
    return MediaQuery.of(this).disableAnimations;
  }

  /// Whether a screen reader is currently active.
  bool get isScreenReaderActive {
    return MediaQuery.of(this).accessibleNavigation;
  }

  /// Whether the system prefers high contrast.
  bool get prefersHighContrast {
    return MediaQuery.of(this).highContrast;
  }

  /// Whether bold text is enabled system-wide.
  bool get prefersBoldText {
    return MediaQuery.of(this).boldText;
  }
}
