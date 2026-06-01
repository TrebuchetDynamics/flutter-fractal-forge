import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'permission_test_harness.dart';

class MainAppA11yHarness {
  late final PresetStore presetStore;
  late final AccessibilityService accessibilityService;
  late final RendererSettingsService rendererSettingsService;
  OnboardingService? onboardingService;

  Future<void> setUp({bool forceOnboarding = false}) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    installDenyAllPermissionsHandler();
    presetStore = await PresetStore.create();
    accessibilityService = await AccessibilityService.create();
    rendererSettingsService = await RendererSettingsService.create();
    if (forceOnboarding) {
      onboardingService = await OnboardingService.create();
    }
  }

  Widget buildApp() {
    return FlutterFractalsApp(
      presetStore: presetStore,
      accessibilityService: accessibilityService,
      rendererSettingsService: rendererSettingsService,
      onboardingService: onboardingService,
      locale: const Locale('en'),
    );
  }
}
