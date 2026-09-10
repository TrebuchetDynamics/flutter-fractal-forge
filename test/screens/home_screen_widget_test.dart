import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import '../a11y/shared/main_app_a11y_harness.dart';

void main() {
  group('HomeScreen via FlutterFractalsApp', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    Widget buildTestWidget() => harness.buildApp();

    testWidgets('starts with catalog visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Forge'), findsOneWidget);
      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    for (final mode in ['normal', 'controls', 'fullscreen']) {
      testWidgets('returns directly to the filtered catalog from $mode view',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Mandelbrot');
        await tester.pumpAndSettle(const Duration(milliseconds: 400));
        final card = find.byWidgetPredicate((widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>)
                .value
                .startsWith('catalogModuleCard_'));
        await tester.tap(card.first);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
        if (mode == 'fullscreen') {
          await tester.tap(find.byTooltip('Fullscreen view'));
          await tester.pumpAndSettle();
        } else if (mode == 'controls') {
          await tester.longPress(
              find.byKey(const ValueKey('viewerRandomParamsButton')));
          await tester.pumpAndSettle();
        }
        final back = find.byKey(const Key('viewerBackToCatalogButton'));
        expect(back, findsOneWidget);
        expect(find.bySemanticsLabel('Back to catalog'), findsOneWidget);
        expect(tester.getSemantics(back).rect.height, greaterThanOrEqualTo(48));
        expect(tester.getSize(back).height,
            greaterThanOrEqualTo(48));
        if (mode == 'normal') {
          Focus.of(tester.element(find.text('Back to catalog'))).requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else {
          await tester.tap(back);
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('fractalViewerRoot')), findsNothing);
        expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Mandelbrot');
        expect(tester.takeException(), isNull);
        semantics.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }

    testWidgets('displays fractal modules in catalog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('catalogModuleCard_');
        }),
        findsWidgets,
      );
      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('has search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('has no bottom tabs; settings opens from gear', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byKey(const Key('homeSettingsButton')), findsOneWidget);

      await tester.tap(find.byKey(const Key('homeSettingsButton')));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets(
        'high contrast toggle changes app theme and restores prior theme',
        (tester) async {
      await harness.accessibilityService.setThemeMode(AppThemeMode.oled);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      ThemeData appTheme() =>
          tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;

      expect(appTheme().primaryColor, AppTheme.oled.primaryColor);

      await harness.accessibilityService.setHighContrast(true);
      await tester.pump();

      expect(harness.accessibilityService.themeMode, AppThemeMode.highContrast);
      expect(appTheme().primaryColor, AppTheme.highContrast.primaryColor);

      await harness.accessibilityService.setHighContrast(false);
      await tester.pump();

      expect(harness.accessibilityService.themeMode, AppThemeMode.oled);
      expect(appTheme().primaryColor, AppTheme.oled.primaryColor);
    });

    testWidgets('large targets setting increases Material control hit areas',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final normalSize = tester.getSize(
        find.byKey(const Key('catalogSearchToggleButton')),
      );

      await harness.accessibilityService.setLargeTargets(true);
      await tester.pump();
      final largeSize = tester.getSize(
        find.byKey(const Key('catalogSearchToggleButton')),
      );

      expect(largeSize.width, greaterThan(normalSize.width));
      expect(largeSize.height, greaterThan(normalSize.height));
      expect(largeSize.shortestSide, greaterThanOrEqualTo(56));
    });

    testWidgets('top app-bar actions expose semantic labels and tooltips',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Search fractals'), findsOneWidget);
      expect(find.bySemanticsLabel('Switch to list view'), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);

      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('catalogSearchToggleButton')),
            )
            .tooltip,
        'Search fractals',
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('catalogViewToggleButton')),
            )
            .tooltip,
        'Switch to list view',
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('homeSettingsButton')))
            .tooltip,
        'Settings',
      );
      semantics.dispose();
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
