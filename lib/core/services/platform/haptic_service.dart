import 'package:flutter/services.dart';

/// Haptic feedback service providing tactile feedback for UI interactions.
class HapticService {
  HapticService();

  /// Light haptic feedback for subtle interactions (sliders, scrolling)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Light haptic with throttling for continuous interactions
  static DateTime? _lastLight;
  static Future<void> lightThrottled(
      {Duration throttle = const Duration(milliseconds: 50)}) async {
    final now = DateTime.now();
    if (_lastLight == null || now.difference(_lastLight!) > throttle) {
      _lastLight = now;
      await light();
    }
  }

  /// Medium haptic feedback for standard button presses
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important events (export complete, errors)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for option/preset selection
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
