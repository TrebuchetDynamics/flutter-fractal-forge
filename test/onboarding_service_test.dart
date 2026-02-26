import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('OnboardingService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isOnboardingComplete returns false on fresh prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);
      expect(service.isOnboardingComplete, isFalse);
    });

    test('completeOnboarding sets flag and version', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();

      expect(prefs.getBool('onboarding_complete'), isTrue);
      expect(prefs.getInt('onboarding_version'), OnboardingService.currentVersion);
    });

    test('isOnboardingComplete returns true after completeOnboarding', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();

      expect(service.isOnboardingComplete, isTrue);
    });

    test('resetOnboarding clears state', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();
      await service.resetOnboarding();

      expect(service.isOnboardingComplete, isFalse);
      expect(prefs.getBool('onboarding_complete'), isNull);
      expect(prefs.getInt('onboarding_version'), isNull);
    });

    test('isOnboardingComplete false if version < currentVersion', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setInt('onboarding_version', 0);

      final service = OnboardingService.withPrefs(prefs);

      expect(service.isOnboardingComplete, isFalse);
    });

    test('withPrefs factory creates valid instance', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      expect(service, isNotNull);
      expect(service.isOnboardingComplete, isFalse);
    });

    test('multiple complete/reset cycles work correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      for (int i = 0; i < 3; i++) {
        await service.completeOnboarding();
        expect(service.isOnboardingComplete, isTrue);

        await service.resetOnboarding();
        expect(service.isOnboardingComplete, isFalse);
      }

      // Final complete should still work
      await service.completeOnboarding();
      expect(service.isOnboardingComplete, isTrue);
    });
  });
}
