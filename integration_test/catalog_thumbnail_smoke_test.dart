/// Smoke test: verify catalog thumbnails load from assets in integration mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Catalog thumbnails load', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // App now starts directly on catalog; verify catalog UI is present.
    expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);

    final assetImages = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName.contains('catalog_thumbs/'),
    );

    debugPrint('Asset thumbnails found: ${assetImages.evaluate().length}');

    // Ensure real thumbnail assets are being used (not just placeholders).
    expect(assetImages.evaluate().length, greaterThan(10));
  });
}
