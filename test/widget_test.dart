import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Fractal app smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final presetStore = await PresetStore.create();
    final arQualityStore = await ArQualityStore.create();
    final accessibilityService = await AccessibilityService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        accessibilityService: accessibilityService,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fractal Catalog'), findsOneWidget);
  });
}
