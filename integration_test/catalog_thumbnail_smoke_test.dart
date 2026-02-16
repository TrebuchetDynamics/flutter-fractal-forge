/// Smoke test: Verify catalog thumbnails load (not gradient fallbacks).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Catalog thumbnails load', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });

    app.main();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Navigate to catalog
    final catalogButton = find.byIcon(Icons.grid_view);
    expect(catalogButton, findsOneWidget);
    await tester.tap(catalogButton);
    await tester.pumpAndSettle();

    // Check that catalog screen loaded
    expect(find.text('ESCAPE-TIME'), findsOneWidget);

    // Look for AssetImage widgets (thumbnails)
    // Gradient fallbacks use LinearGradient, not AssetImage
    final assetImages = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage)
              .assetName
              .contains('catalog_thumbs/'),
    );

    final fallbacks = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration != null &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null,
    );

    debugPrint('Asset thumbnails found: ${assetImages.evaluate().length}');
    debugPrint('Gradient fallbacks found: ${fallbacks.evaluate().length}');

    // At least 10 real thumbnails should load (catalog has 197 entries)
    expect(assetImages.evaluate().length, greaterThan(10),
        reason: 'Expected asset thumbnails to load, not gradient fallbacks');
  });
}
