import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService', () {
    // Capture all method channel calls so HapticFeedback calls don't throw
    // in the test environment.
    final List<MethodCall> log = [];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('light feedback does not throw', () async {
      await expectLater(HapticService.light(), completes);
    });

    test('medium feedback does not throw', () async {
      await expectLater(HapticService.medium(), completes);
    });

    test('heavy feedback does not throw', () async {
      await expectLater(HapticService.heavy(), completes);
    });

    test('selection feedback does not throw', () async {
      await expectLater(HapticService.selection(), completes);
    });

    test('vibrate feedback does not throw', () async {
      await expectLater(HapticService.vibrate(), completes);
    });

    test('light feedback triggers HapticFeedback.lightImpact', () async {
      await HapticService.light();
      expect(
        log.any((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.lightImpact'),
        isTrue,
      );
    });

    test('medium feedback triggers HapticFeedback.mediumImpact', () async {
      await HapticService.medium();
      expect(
        log.any((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.mediumImpact'),
        isTrue,
      );
    });

    test('heavy feedback triggers HapticFeedback.heavyImpact', () async {
      await HapticService.heavy();
      expect(
        log.any((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.heavyImpact'),
        isTrue,
      );
    });

    test('selection feedback triggers HapticFeedback.selectionClick', () async {
      await HapticService.selection();
      expect(
        log.any((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.selectionClick'),
        isTrue,
      );
    });

    test('lightThrottled does not throw on first call', () async {
      await expectLater(
        HapticService.lightThrottled(),
        completes,
      );
    });

    test('lightThrottled suppresses rapid successive calls', () async {
      log.clear();
      await HapticService.lightThrottled(throttle: const Duration(seconds: 10));
      final countAfterFirst = log.length;

      // Second call immediately — throttle window not expired.
      await HapticService.lightThrottled(throttle: const Duration(seconds: 10));
      final countAfterSecond = log.length;

      // The second call should have been throttled (no extra platform calls).
      expect(countAfterSecond, countAfterFirst);
    });

    test('HapticService can be instantiated', () {
      expect(() => HapticService(), returnsNormally);
    });
  });
}
