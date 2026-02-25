import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';

void main() {
  group('OnboardingService unit tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isOnboardingComplete returns false when never completed', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);
      expect(service.isOnboardingComplete, isFalse);
    });

    test('completeOnboarding sets state to complete', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();

      expect(service.isOnboardingComplete, isTrue);
    });

    test('isOnboardingComplete persists across instances', () async {
      final prefs = await SharedPreferences.getInstance();
      final service1 = OnboardingService.withPrefs(prefs);
      await service1.completeOnboarding();

      // Create a second instance with the same prefs
      final service2 = OnboardingService.withPrefs(prefs);
      expect(service2.isOnboardingComplete, isTrue);
    });

    test('isOnboardingComplete returns false when version is outdated', () async {
      final prefs = await SharedPreferences.getInstance();
      // Simulate an older version completing onboarding
      await prefs.setBool('onboarding_complete', true);
      await prefs.setInt('onboarding_version', 0); // version 0 < currentVersion 1

      final service = OnboardingService.withPrefs(prefs);
      expect(service.isOnboardingComplete, isFalse);
    });

    test('resetOnboarding clears completion state', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();
      expect(service.isOnboardingComplete, isTrue);

      await service.resetOnboarding();
      expect(service.isOnboardingComplete, isFalse);
    });

    test('currentVersion is a positive integer', () {
      expect(OnboardingService.currentVersion, greaterThan(0));
    });

    test('completeOnboarding stores current version', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);
      await service.completeOnboarding();

      final storedVersion = prefs.getInt('onboarding_version');
      expect(storedVersion, OnboardingService.currentVersion);
    });

    test('resetOnboarding allows re-completion', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService.withPrefs(prefs);

      await service.completeOnboarding();
      await service.resetOnboarding();
      await service.completeOnboarding();

      expect(service.isOnboardingComplete, isTrue);
    });
  });
}
