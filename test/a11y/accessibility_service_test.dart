import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';

/// Delays only the first preference write, leaving service state untouched.
class _DelayedThemePreferences implements SharedPreferences {
  _DelayedThemePreferences(this.delegate);

  final SharedPreferences delegate;
  final writeStarted = Completer<void>();
  final releaseWrite = Completer<void>();

  Future<bool> _write(Future<bool> Function() persist) async {
    if (!writeStarted.isCompleted) {
      writeStarted.complete();
      await releaseWrite.future;
    }
    return persist();
  }

  @override
  Object? get(String key) => delegate.get(key);

  @override
  bool? getBool(String key) => delegate.getBool(key);

  @override
  int? getInt(String key) => delegate.getInt(key);

  @override
  Future<bool> setInt(String key, int value) =>
      _write(() => delegate.setInt(key, value));

  @override
  Future<bool> setBool(String key, bool value) =>
      _write(() => delegate.setBool(key, value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccessibilityService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('theme request ordering', () {
      test(
          'contrast off survives a pending contrast on write and restores OLED',
          () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 1});
        final stored = await SharedPreferences.getInstance();
        final prefs = _DelayedThemePreferences(stored);
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);
        final notifications = <(AppThemeMode, bool, int?, int?, bool?)>[];
        service.addListener(() => notifications.add((
              service.themeMode,
              service.highContrastEnabled,
              stored.getInt('app_theme_mode'),
              stored.getInt('app_previous_theme_mode'),
              stored.getBool('accessibility_high_contrast'),
            )));

        final enabling = service.setHighContrast(true);
        await prefs.writeStarted.future;
        final disabling = service.setHighContrast(false);
        expect(notifications, isEmpty);
        prefs.releaseWrite.complete();
        await Future.wait([enabling, disabling])
            .timeout(const Duration(seconds: 5));

        expect(service.themeMode, AppThemeMode.oled);
        expect(service.highContrastEnabled, isFalse);
        expect(stored.getInt('app_theme_mode'), 1);
        expect(stored.getInt('app_previous_theme_mode'), 1);
        expect(stored.getBool('accessibility_high_contrast'), isFalse);
        expect(notifications, [
          (AppThemeMode.highContrast, true, 2, 1, true),
          (AppThemeMode.oled, false, 1, 1, false),
        ]);
      });

      test('interleaved theme and contrast requests persist in call order',
          () async {
        final stored = await SharedPreferences.getInstance();
        final prefs = _DelayedThemePreferences(stored);
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);
        final notifications = <(AppThemeMode, bool, int?, int?, bool?)>[];
        service.addListener(() => notifications.add((
              service.themeMode,
              service.highContrastEnabled,
              stored.getInt('app_theme_mode'),
              stored.getInt('app_previous_theme_mode'),
              stored.getBool('accessibility_high_contrast'),
            )));

        final oled = service.setThemeMode(AppThemeMode.oled);
        await prefs.writeStarted.future;
        final requests = [
          oled,
          service.setThemeMode(AppThemeMode.oled),
          service.setHighContrast(true),
          service.setHighContrast(true),
          service.setThemeMode(AppThemeMode.dark),
          service.setThemeMode(AppThemeMode.highContrast),
          service.setHighContrast(false),
          service.setHighContrast(false),
        ];
        expect(notifications, isEmpty);
        prefs.releaseWrite.complete();
        await Future.wait(requests).timeout(const Duration(seconds: 5));

        expect(service.themeMode, AppThemeMode.dark);
        expect(service.highContrastEnabled, isFalse);
        expect(stored.getInt('app_theme_mode'), 0);
        expect(stored.getInt('app_previous_theme_mode'), 0);
        expect(stored.getBool('accessibility_high_contrast'), isFalse);
        expect(notifications, [
          (AppThemeMode.oled, false, 1, 1, false),
          (AppThemeMode.highContrast, true, 2, 1, true),
          (AppThemeMode.dark, false, 0, 0, false),
          (AppThemeMode.highContrast, true, 2, 0, true),
          (AppThemeMode.dark, false, 0, 0, false),
        ]);
      });

      for (final failContrast in [true, false]) {
        test(
            '${failContrast ? 'contrast' : 'theme'} write failure reaches caller without poisoning later requests',
            () async {
          final stored = await SharedPreferences.getInstance();
          final prefs = _DelayedThemePreferences(stored);
          final service = AccessibilityService(prefs);
          addTearDown(service.dispose);
          var notifications = 0;
          service.addListener(() => notifications++);
          final error = StateError('preference write failed');
          final failed = failContrast
              ? service.setHighContrast(true)
              : service.setThemeMode(AppThemeMode.oled);
          final failure = expectLater(failed, throwsA(same(error)));
          await prefs.writeStarted.future;
          final recovery = failContrast
              ? service.setThemeMode(AppThemeMode.oled)
              : service.setHighContrast(true);
          prefs.releaseWrite.completeError(error);
          await Future.wait([failure, recovery])
              .timeout(const Duration(seconds: 5));

          expect(notifications, 1);
          expect(service.themeMode,
              failContrast ? AppThemeMode.oled : AppThemeMode.highContrast);
          expect(service.highContrastEnabled, !failContrast);
          expect(stored.getInt('app_theme_mode'), failContrast ? 1 : 2);
          expect(stored.getInt('app_previous_theme_mode'), 1);
          expect(stored.getBool('accessibility_high_contrast'), !failContrast);

          // A different request recovers; no rollback or same-request retry
          // policy is imposed on the failed operation's in-memory changes.
          await service.setHighContrast(false);
          expect(service.themeMode, AppThemeMode.oled);
          expect(service.highContrastEnabled, isFalse);
          expect(stored.getInt('app_theme_mode'), 1);
          expect(stored.getInt('app_previous_theme_mode'), 1);
          expect(stored.getBool('accessibility_high_contrast'), isFalse);
          expect(notifications, failContrast ? 1 : 2);
        });

        test(
            'pending ${failContrast ? 'contrast' : 'theme'} and later requests persist after disposal without notifying',
            () async {
          final stored = await SharedPreferences.getInstance();
          final prefs = _DelayedThemePreferences(stored);
          final service = AccessibilityService(prefs);
          var notifications = 0;
          service.addListener(() => notifications++);
          final first = failContrast
              ? service.setHighContrast(true)
              : service.setThemeMode(AppThemeMode.oled);
          await prefs.writeStarted.future;
          final later = service.setThemeMode(AppThemeMode.dark);
          service.dispose();
          prefs.releaseWrite.complete();
          await Future.wait([first, later]).timeout(const Duration(seconds: 5));

          expect(notifications, 0);
          expect(service.themeMode, AppThemeMode.dark);
          expect(service.highContrastEnabled, isFalse);
          expect(stored.getInt('app_theme_mode'), 0);
          expect(stored.getInt('app_previous_theme_mode'), 0);
          expect(stored.getBool('accessibility_high_contrast'), isFalse);
        });
      }

      test('awaited theme no-ops keep persistence and notifications unchanged',
          () async {
        final prefs = await SharedPreferences.getInstance();
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);
        var notifications = 0;
        service.addListener(() => notifications++);

        await service.setThemeMode(AppThemeMode.dark);
        await service.setHighContrast(false);
        expect(prefs.getKeys(), isEmpty);
        expect(notifications, 0);

        await service.setThemeMode(AppThemeMode.oled);
        await service.setHighContrast(true);
        await service.setThemeMode(AppThemeMode.highContrast);
        await service.setHighContrast(true);
        await service.setHighContrast(false);
        await service.setHighContrast(false);
        await service.setThemeMode(AppThemeMode.oled);

        expect(notifications, 3);
        expect(service.themeMode, AppThemeMode.oled);
        expect(service.highContrastEnabled, isFalse);
        expect(prefs.getInt('app_theme_mode'), 1);
        expect(prefs.getInt('app_previous_theme_mode'), 1);
        expect(prefs.getBool('accessibility_high_contrast'), isFalse);
      });
    });

    group('startup preference types', () {
      test('corrupt high contrast flag defaults without losing OLED theme',
          () async {
        final stored = <String, Object>{
          'accessibility_high_contrast': 'true',
          'accessibility_reduced_motion': true,
          'app_theme_mode': AppThemeMode.oled.index,
        };
        SharedPreferences.setMockInitialValues(stored);
        final prefs = await SharedPreferences.getInstance();
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);

        expect(service.highContrastEnabled, isFalse);
        expect(service.themeMode, AppThemeMode.oled);
        expect(service.reducedMotionEnabled, isTrue);
        expect(service.largeTargetsEnabled, isFalse);
        expect(
            {for (final key in prefs.getKeys()) key: prefs.get(key)}, stored);
      });

      test(
          'create defaults corrupt reduced motion without losing previous OLED',
          () async {
        final stored = <String, Object>{
          'accessibility_high_contrast': true,
          'accessibility_reduced_motion': 1,
          'accessibility_large_targets': true,
          'app_theme_mode': AppThemeMode.highContrast.index,
          'app_previous_theme_mode': AppThemeMode.oled.index,
        };
        SharedPreferences.setMockInitialValues(stored);
        final service = await AccessibilityService.create();
        addTearDown(service.dispose);
        final prefs = await SharedPreferences.getInstance();

        expect(service.reducedMotionEnabled, isFalse);
        expect(service.largeTargetsEnabled, isTrue);
        expect(service.highContrastEnabled, isTrue);
        expect(service.themeMode, AppThemeMode.highContrast);
        expect(
            {for (final key in prefs.getKeys()) key: prefs.get(key)}, stored);

        await service.setHighContrast(false);
        expect(service.themeMode, AppThemeMode.oled);
      });

      test('corrupt large targets keeps reduced motion and OLED theme',
          () async {
        final stored = <String, Object>{
          'accessibility_high_contrast': false,
          'accessibility_reduced_motion': true,
          'accessibility_large_targets': <String>['true'],
          'app_theme_mode': AppThemeMode.oled.index,
        };
        SharedPreferences.setMockInitialValues(stored);
        final prefs = await SharedPreferences.getInstance();
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);

        expect(service.largeTargetsEnabled, isFalse);
        expect(service.reducedMotionEnabled, isTrue);
        expect(service.highContrastEnabled, isFalse);
        expect(service.themeMode, AppThemeMode.oled);
        expect(
            {for (final key in prefs.getKeys()) key: prefs.get(key)}, stored);
      });

      test('create defaults corrupt theme index without losing valid flags',
          () async {
        final stored = <String, Object>{
          'accessibility_reduced_motion': true,
          'accessibility_large_targets': true,
          'app_theme_mode': 1.0,
        };
        SharedPreferences.setMockInitialValues(stored);
        final service = await AccessibilityService.create();
        addTearDown(service.dispose);
        final prefs = await SharedPreferences.getInstance();

        expect(service.themeMode, AppThemeMode.dark);
        expect(service.highContrastEnabled, isFalse);
        expect(service.reducedMotionEnabled, isTrue);
        expect(service.largeTargetsEnabled, isTrue);
        expect(
            {for (final key in prefs.getKeys()) key: prefs.get(key)}, stored);
      });

      test('corrupt previous theme falls back to legacy OLED theme', () async {
        final stored = <String, Object>{
          'accessibility_high_contrast': true,
          'accessibility_reduced_motion': true,
          'app_theme_mode': AppThemeMode.oled.index,
          'app_previous_theme_mode': false,
        };
        SharedPreferences.setMockInitialValues(stored);
        final prefs = await SharedPreferences.getInstance();
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);

        expect(service.highContrastEnabled, isTrue);
        expect(service.themeMode, AppThemeMode.highContrast);
        expect(service.reducedMotionEnabled, isTrue);
        expect(
            {for (final key in prefs.getKeys()) key: prefs.get(key)}, stored);

        await service.setHighContrast(false);
        expect(service.themeMode, AppThemeMode.oled);
        expect(service.highContrastEnabled, isFalse);
      });
    });

    group('startup preference compatibility', () {
      test('missing theme preferences default to dark without writing keys',
          () async {
        final prefs = await SharedPreferences.getInstance();
        final service = AccessibilityService(prefs);
        addTearDown(service.dispose);

        expect(service.themeMode, AppThemeMode.dark);
        expect(prefs.getKeys(), isEmpty);
      });

      for (final index in [-100, 100]) {
        test('theme and previous theme clamp integer index $index', () async {
          SharedPreferences.setMockInitialValues({
            'app_theme_mode': index,
            'app_previous_theme_mode': index,
          });
          final prefs = await SharedPreferences.getInstance();
          final service = AccessibilityService(prefs);
          addTearDown(service.dispose);

          expect(service.themeMode,
              index < 0 ? AppThemeMode.dark : AppThemeMode.highContrast);
          expect(service.highContrastEnabled, index > 0);
          expect(prefs.getInt('app_theme_mode'), index);
          expect(prefs.getInt('app_previous_theme_mode'), index);

          SharedPreferences.setMockInitialValues({
            'accessibility_high_contrast': true,
            'app_theme_mode': AppThemeMode.oled.index,
            'app_previous_theme_mode': index,
          });
          final restored = await AccessibilityService.create();
          addTearDown(restored.dispose);
          await restored.setHighContrast(false);
          expect(restored.themeMode, AppThemeMode.dark);
        });
      }

      test('legacy high contrast theme without previous theme restores dark',
          () async {
        SharedPreferences.setMockInitialValues({
          'app_theme_mode': AppThemeMode.highContrast.index,
        });
        final service = await AccessibilityService.create();
        addTearDown(service.dispose);

        expect(service.highContrastEnabled, isTrue);
        expect(service.themeMode, AppThemeMode.highContrast);
        await service.setHighContrast(false);
        expect(service.themeMode, AppThemeMode.dark);
      });
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

    test('legacy high contrast state restores its persisted prior theme',
        () async {
      SharedPreferences.setMockInitialValues({
        'accessibility_high_contrast': true,
        'app_theme_mode': AppThemeMode.oled.index,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AccessibilityService(prefs);

      expect(service.themeMode, AppThemeMode.highContrast);

      await service.setHighContrast(false);

      expect(service.themeMode, AppThemeMode.oled);
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
