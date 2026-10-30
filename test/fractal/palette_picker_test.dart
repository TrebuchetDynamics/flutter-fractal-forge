import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/permission_test_harness.dart';
import '../helpers/overflow_guard.dart';

void main() {
  group('palette picker', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late RendererSettingsService rendererSettings;
    late HistoryStore historyStore;
    late HistoryProvider historyProvider;
    late PaletteService paletteService;
    bool paletteDisposed = false;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      paletteDisposed = false;
      SharedPreferences.setMockInitialValues({});
      installDenyAllPermissionsHandler();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());
      historyStore = await HistoryStore.create();
      historyProvider = HistoryProvider(store: historyStore);
      paletteService = await PaletteService.create();
    });

    tearDown(() {
      historyProvider.dispose();
      controller.dispose();
      rendererSettings.dispose();
      if (!paletteDisposed) paletteService.dispose();
    });

    Widget buildTestWidget({
      double textScale = 1.0,
      ThemeData? theme,
      Locale locale = const Locale('en'),
    }) =>
        MultiProvider(
          providers: [
            Provider.value(value: registry),
            ChangeNotifierProvider.value(value: controller),
            Provider.value(value: presetStore),
            ChangeNotifierProvider.value(value: rendererSettings),
            ChangeNotifierProvider.value(value: historyProvider),
          ],
          child: MaterialApp(
            theme: theme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const FractalViewerScreen(),
          ),
        );

    Future<void> openPicker(
      WidgetTester tester, {
      double textScale = 1.0,
      ThemeData? theme,
      Locale locale = const Locale('en'),
    }) async {
      await tester.pumpWidget(
        buildTestWidget(textScale: textScale, theme: theme, locale: locale),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerPaletteButton')));
      await tester.pumpAndSettle();
    }

    testWidgets('normal initial selection retains visible title and close',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await openPicker(tester, theme: AppTheme.dark);
      expect(find.byType(AppBottomSheetHeader).hitTestable(), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded).hitTestable(), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded).hitTestable(),
          findsOneWidget);
      final selected = tester.widget<AnimatedContainer>(find.descendant(
          of: find.byKey(const ValueKey('paletteChoice0')),
          matching: find.byType(AnimatedContainer)));
      final unselected = tester.widget<AnimatedContainer>(find.descendant(
          of: find.byKey(const ValueKey('paletteChoice1')),
          matching: find.byType(AnimatedContainer)));
      final selectedDecoration = selected.decoration! as BoxDecoration;
      final unselectedDecoration = unselected.decoration! as BoxDecoration;
      expect(
          selectedDecoration.color, AppTheme.dark.colorScheme.primaryContainer);
      expect((selectedDecoration.border! as Border).top.color,
          AppTheme.dark.colorScheme.primary);
      expect((unselectedDecoration.border! as Border).top.color,
          Colors.transparent,
          reason: 'Unselected outlines must not overwhelm the selected state');
    });

    testWidgets('opens with a deep selected palette visible', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      controller.updateParam('colorScheme', 63);

      await openPicker(tester);

      expect(
        find.byIcon(Icons.check_circle_rounded),
        findsOneWidget,
        reason: 'the selected palette starts outside the lazy grid viewport',
      );
    });

    testWidgets(
        'desktop picker reveals a middle selection inside its capped panel',
        (tester) async {
      const size = Size(1440, 900);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.binding.setSurfaceSize(size);
      addTearDown(() async {
        tester.view.reset();
        await tester.binding.setSurfaceSize(null);
      });
      controller.updateParam('colorScheme', 31);
      await openPicker(tester, theme: AppTheme.dark);
      final selected = find.byIcon(Icons.check_circle_rounded);
      expect(selected, findsOneWidget);
      final grid =
          tester.getRect(find.byKey(const ValueKey('palettePickerScroll')));
      final marker = tester.getRect(selected);
      expect(marker.top, greaterThanOrEqualTo(grid.top));
      expect(marker.bottom, lessThanOrEqualTo(grid.bottom));
    });
    testWidgets('sheet and selection follow the active color system',
        (tester) async {
      await openPicker(tester, theme: AppTheme.highContrast);

      final sheetContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppBottomSheet),
              matching: find.byType(Container),
            )
            .first,
      );
      final sheetDecoration = sheetContainer.decoration! as BoxDecoration;
      expect(sheetDecoration.color, HighContrastColors.surface);

      final selectedIcon = tester.widget<Icon>(
        find.byIcon(Icons.check_circle_rounded),
      );
      expect(selectedIcon.color, HighContrastColors.primary);
    });

    testWidgets('previews preserve authored palette stop positions',
        (tester) async {
      await openPicker(tester);

      final gradients = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.gradient)
          .whereType<LinearGradient>();
      final firePreview = gradients.firstWhere(
        (gradient) => gradient.colors.length == 4,
      );

      expect(firePreview.stops, [0.0, 0.35, 0.7, 1.0]);
    });

    testWidgets('marks exactly one palette as selected for screen readers',
        (tester) async {
      final handle = tester.ensureSemantics();
      await openPicker(tester);
      expect(find.byKey(const ValueKey('palettePickerScroll')), findsOneWidget);

      final selected = <String>[];
      void walk(SemanticsNode node) {
        if (!node.isMergedIntoParent) {
          final data = node.getSemanticsData();
          if (data.flagsCollection.isSelected == Tristate.isTrue) {
            selected.add(data.label);
          }
        }
        node.visitChildren((child) {
          walk(child);
          return true;
        });
      }

      // Semantics live on this pipeline owner; rootPipelineOwner.semanticsOwner
      // is null in a widget test. Matches test/a11y/semantics/.
      // ignore: deprecated_member_use
      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

      // The active palette is otherwise signalled only by a check icon and a
      // border colour, neither of which reaches a screen reader.
      expect(
        selected,
        hasLength(1),
        reason: 'the active palette carries no selected state',
      );
      expect(selected.single, isNotEmpty, reason: 'selected tile is unnamed');

      handle.dispose();
    });

    for (final locale in const [Locale('en'), Locale('es')]) {
      for (final width in [320.0, 360.0, 390.0]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          testWidgets('full palette labels fit ${width}px ${scale}x $locale',
              (tester) async {
            await tester.binding.setSurfaceSize(Size(width, 720));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            controller.updateParam('colorScheme', 13);
            await openPicker(tester,
                textScale: scale, locale: locale, theme: AppTheme.highContrast);
            final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
            final delegate =
                grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
            if (width == 320 && scale >= 2) {
              expect(delegate.crossAxisCount, 1,
                  reason:
                      'measure width and scaled label needs, not fixed scale breakpoints');
            }
            final selected = find.byKey(const ValueKey('paletteChoice13'));
            expect(selected.hitTestable(), findsOneWidget);
            final label =
                find.descendant(of: selected, matching: find.byType(Text));
            expect(tester.widget<Text>(label).maxLines, isNull,
                reason: 'palette names must not be ellipsized');
            final paragraph = tester.renderObject<RenderParagraph>(label);
            final text = tester.widget<Text>(label).data!;
            for (final word in RegExp(r'\S+').allMatches(text)) {
              expect(
                  paragraph
                      .getBoxesForSelection(TextSelection(
                          baseOffset: word.start, extentOffset: word.end))
                      .length,
                  1,
                  reason: 'No mid-word breaks in $text');
            }
            final target = tester.getSize(selected);
            expect(target.width, greaterThanOrEqualTo(48));
            expect(target.height, greaterThanOrEqualTo(48));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('selecting a palette updates the controller and actual preview',
        (tester) async {
      controller.updateParam('colorScheme', 13);
      await openPicker(tester);
      final target = find.byKey(const ValueKey('paletteChoice14'));
      await tester.scrollUntilVisible(target, 150,
          scrollable: find.descendant(
              of: find.byKey(const ValueKey('palettePickerScroll')),
              matching: find.byType(Scrollable)));
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(controller.params['colorScheme'], 14);
      final palette = paletteService.paletteAtIndex(14);
      final preview = tester
          .widgetList<DecoratedBox>(
              find.descendant(of: target, matching: find.byType(DecoratedBox)))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.gradient)
          .whereType<LinearGradient>()
          .single;
      expect(preview.colors,
          [for (final stop in palette.stops) Color(stop.colorArgb)]);
      expect(preview.stops, [for (final stop in palette.stops) stop.position]);
      expect(
          find.descendant(
              of: target, matching: find.byIcon(Icons.check_circle_rounded)),
          findsOneWidget);
    });

    testWidgets(
        'every indexed preview uses actual stops and final palette is selectable',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await openPicker(tester, textScale: 3, locale: const Locale('es'));
      for (var i = 0; i < 64; i++) {
        final tile = find.byKey(ValueKey('paletteChoice$i'));
        await tester.scrollUntilVisible(tile, 150,
            maxScrolls: 100,
            scrollable: find.descendant(
                of: find.byKey(const ValueKey('palettePickerScroll')),
                matching: find.byType(Scrollable)));
        final preview = tester
            .widgetList<DecoratedBox>(
                find.descendant(of: tile, matching: find.byType(DecoratedBox)))
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .map((d) => d.gradient)
            .whereType<LinearGradient>()
            .single;
        final palette = paletteService.paletteAtIndex(i);
        expect(preview.colors,
            [for (final stop in palette.stops) Color(stop.colorArgb)],
            reason: 'actual preview $i');
        expect(
            preview.stops, [for (final stop in palette.stops) stop.position]);
      }
      final finalTile = find.byKey(const ValueKey('paletteChoice63'));
      await tester.ensureVisible(finalTile);
      await tester.pumpAndSettle();
      expect(finalTile.hitTestable(), findsOneWidget);
      await tester.tap(finalTile);
      await tester.pumpAndSettle();
      expect(controller.params['colorScheme'], 63);
      expect(
          find.descendant(
              of: finalTile, matching: find.byIcon(Icons.check_circle_rounded)),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final language in ['en', 'es']) {
      testWidgets('short landscape retains final palette and close ($language)',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(640, 320));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        controller.updateParam('colorScheme', 63);
        await openPicker(tester,
            textScale: 3,
            locale: Locale(language),
            theme: AppTheme.highContrast);
        final grid = find.byKey(const ValueKey('palettePickerScroll'));
        final finalTile = find.byKey(const ValueKey('paletteChoice63'));
        expect(finalTile, findsOneWidget);
        final label =
            find.descendant(of: finalTile, matching: find.byType(Text));
        await tester.ensureVisible(label);
        await tester.pumpAndSettle();
        expect(label.hitTestable(), findsOneWidget);
        expect(tester.getRect(label).bottom,
            lessThanOrEqualTo(tester.getRect(grid).bottom));
        final scroll = tester.widget<CustomScrollView>(grid).controller!;
        scroll.jumpTo(0);
        await tester.pumpAndSettle();
        final close = find.byIcon(Icons.close_rounded);
        expect(close.hitTestable(), findsOneWidget);
        expect(
            tester
                .getSize(find
                    .ancestor(of: close, matching: find.byType(GestureDetector))
                    .first)
                .height,
            greaterThanOrEqualTo(48));
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(grid, findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('missing palette service does not invent a gradient',
        (tester) async {
      paletteService.dispose();
      paletteDisposed = true;
      await openPicker(tester);
      final gradients = tester
          .widgetList<DecoratedBox>(find.descendant(
              of: find.byKey(const ValueKey('palettePickerScroll')),
              matching: find.byType(DecoratedBox)))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.gradient)
          .whereType<LinearGradient>();
      expect(gradients, isEmpty);
      expect(find.byIcon(Icons.palette_outlined), findsWidgets);
      expect(
          tester
              .widgetList<Semantics>(find.descendant(
                  of: find.byKey(const ValueKey('palettePickerScroll')),
                  matching: find.byType(Semantics)))
              .any((node) =>
                  node.properties.hint == 'Palette preview unavailable'),
          isTrue);
    });

    for (final scale in const [1.0, 1.5, 2.0]) {
      testWidgets('picker grid survives a ${scale}x text scale',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await expectNoOverflow(
          () => openPicker(tester, textScale: scale),
          reason: 'at $scale x',
        );
      });
    }
  });
}
