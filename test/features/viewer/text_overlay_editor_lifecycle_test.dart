import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

void main() {
  testWidgets('text overlay editor owns its controller through route dismissal',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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

    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      'core.mandelbrot',
    );
    await tester.pump(const Duration(milliseconds: 700));
    final card =
        find.byKey(const ValueKey('catalogModuleCard_core.mandelbrot'));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
    await tester.pump(const Duration(milliseconds: 500));
    final options = find.byKey(const ValueKey('viewerTextOverlayFabOptions'));
    await tester.ensureVisible(options);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(options);
    await tester.pump(const Duration(milliseconds: 500));
    expect(
        find.byKey(const ValueKey('viewerTextOverlayField')), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 1100);
    tester.binding.handleMetricsChanged();
    await tester.pump();

    final fieldContext = tester.element(
      find.byKey(const ValueKey('viewerTextOverlayField')),
    );
    expect(MediaQuery.viewInsetsOf(fieldContext).bottom, 1100);
    final sheet = find.ancestor(
        of: find.byKey(const ValueKey('viewerTextOverlayField')),
        matching: find.byType(AppBottomSheet));
    expect(sheet, findsOneWidget);
    final insets = find
        .descendant(
          of: sheet,
          matching: find.ancestor(
              of: find.byKey(const ValueKey('viewerTextOverlayField')),
              matching: find.byType(Padding)),
        )
        .evaluate()
        .map((element) =>
            (element.widget as Padding).padding.resolve(TextDirection.ltr))
        .where((padding) =>
            padding.left == 0 &&
            padding.top == 0 &&
            padding.right == 0 &&
            padding.bottom > 0)
        .map((padding) => padding.bottom)
        .toList();
    expect(insets, unorderedEquals([AppSpacing.xl, 1100 - AppSpacing.xl]),
        reason: 'Require exactly one inner navigation and one outer IME inset');
    expect(insets.fold<double>(0, (sum, bottom) => sum + bottom), 1100,
        reason:
            'Actual inner and outer padding must sum to one keyboard inset');

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('viewerTextOverlayField')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
