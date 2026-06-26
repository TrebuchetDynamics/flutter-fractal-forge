import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccessibilityService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('create factory method returns an AccessibilityService instance',
        () async {
      final service = await AccessibilityService.create();
      expect(service, isA<AccessibilityService>());
    });

    test('highContrastEnabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);
      expect(service.highContrastEnabled, isFalse);
    });

    test('reducedMotionEnabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);
      expect(service.reducedMotionEnabled, isFalse);
    });

    test('largeTargetsEnabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);
      expect(service.largeTargetsEnabled, isFalse);
    });

    test('setHighContrast flips state to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setHighContrast(true);

      expect(service.highContrastEnabled, isTrue);
    });

    test('setHighContrast persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setHighContrast(true);

      expect(prefs.getBool('accessibility_high_contrast'), isTrue);
    });

    test('setHighContrast restores previous value when set back to false',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setHighContrast(true);
      await service.setHighContrast(false);

      expect(service.highContrastEnabled, isFalse);
    });

    test('setHighContrast is a no-op when value has not changed', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      // Default is false — setting false again should not notify.
      await service.setHighContrast(false);

      expect(notifyCount, 0);
    });

    test('setReducedMotion flips state to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setReducedMotion(true);

      expect(service.reducedMotionEnabled, isTrue);
    });

    test('setReducedMotion persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setReducedMotion(true);

      expect(prefs.getBool('accessibility_reduced_motion'), isTrue);
    });

    test('setLargeTargets flips state to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setLargeTargets(true);

      expect(service.largeTargetsEnabled, isTrue);
    });

    test('setLargeTargets persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      await service.setLargeTargets(true);

      expect(prefs.getBool('accessibility_large_targets'), isTrue);
    });

    test('constructor restores persisted high contrast value', () async {
      SharedPreferences.setMockInitialValues({
        'accessibility_high_contrast': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      expect(service.highContrastEnabled, isTrue);
    });

    test('constructor restores persisted reduced motion value', () async {
      SharedPreferences.setMockInitialValues({
        'accessibility_reduced_motion': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      expect(service.reducedMotionEnabled, isTrue);
    });

    test('constructor restores persisted large targets value', () async {
      SharedPreferences.setMockInitialValues({
        'accessibility_large_targets': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      expect(service.largeTargetsEnabled, isTrue);
    });

    test('notifyListeners is called when highContrast changes', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      await service.setHighContrast(true);

      expect(notifyCount, 1);
    });

    test('notifyListeners is called when reducedMotion changes', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      await service.setReducedMotion(true);

      expect(notifyCount, 1);
    });

    test('announce static method does not throw', () async {
      // SemanticsService.announce is a no-op in the test environment;
      // the only requirement is that the call does not throw.
      expect(
        () => AccessibilityService.announce('Test message'),
        returnsNormally,
      );
    });

    test('announce with assertive politeness does not throw', () {
      expect(
        () => AccessibilityService.announce(
          'Urgent message',
          politeness: Assertiveness.assertive,
        ),
        returnsNormally,
      );
    });
  });
}
