import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';

/// Helper to create mock accessibility service for tests.
///
/// Usage:
/// ```dart
/// final accessibilityService = await createMockAccessibilityService();
/// ```
Future<AccessibilityService> createMockAccessibilityService({
  bool highContrast = false,
  bool reducedMotion = false,
  bool largeTargets = false,
}) async {
  SharedPreferences.setMockInitialValues({
    'accessibility_high_contrast': highContrast,
    'accessibility_reduced_motion': reducedMotion,
    'accessibility_large_targets': largeTargets,
  });
  return AccessibilityService.create();
}
