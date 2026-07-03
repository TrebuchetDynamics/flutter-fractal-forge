import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Fractal app smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();
    final onboardingService = await OnboardingService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        onboardingService: onboardingService,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(onboardingService.isOnboardingComplete, isFalse);
    expect(find.text('Welcome to Fractal Forge'), findsNothing);
    expect(find.text('Fractal Forge'), findsOneWidget);
    expect(find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
  });
}
