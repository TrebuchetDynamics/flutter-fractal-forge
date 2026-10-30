import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ModuleRegistry registry;
  late FractalController controller;
  late PresetStore presets;
  late RendererSettingsService settings;
  late HistoryProvider history;
  late AccessibilityService accessibility;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    registry = ModuleRegistry();
    controller = FractalController(registry);
    presets = await PresetStore.create();
    final prefs = await SharedPreferences.getInstance();
    settings = RendererSettingsService(prefs);
    history = HistoryProvider(store: await HistoryStore.create());
    accessibility = AccessibilityService(prefs);
  });
  tearDown(() {
    controller.dispose();
    settings.dispose();
    history.dispose();
    accessibility.dispose();
  });

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(320, 200),
    double scale = 1,
    bool more = false,
    bool large = false,
    Locale locale = const Locale('en'),
    EdgeInsets gestures = EdgeInsets.zero,
    EdgeInsets padding = const EdgeInsets.only(top: 24, bottom: 48),
    EdgeInsets viewPadding = const EdgeInsets.only(top: 24, bottom: 48),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await accessibility.setLargeTargets(large);
    if (more) await settings.setDebugModeEnabled(true);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider.value(value: registry),
        ChangeNotifierProvider.value(value: controller),
        Provider.value(value: presets),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider.value(value: accessibility),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            padding: padding,
            viewPadding: viewPadding,
            systemGestureInsets: gestures,
          ),
          child: child!,
        ),
        home: const Scaffold(body: Text('Catalog route')),
      ),
    ));
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
              builder: (_) => const FractalViewerScreen(
                    restoreViewerSession: false,
                  )),
        );
    await tester.pumpAndSettle();
    final controls = find
        .byKey(ValueKey(more ? 'viewerOverflowMenu' : 'viewerControlsButton'));
    if (!more && controls.evaluate().isEmpty) {
      final overflow = find.byKey(const ValueKey('viewerOverflowMenu'));
      await tester.ensureVisible(overflow);
      await tester.pumpAndSettle();
      await tester.tap(overflow);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(controls);
    await tester.pumpAndSettle();
    expect(controls.hitTestable(), findsOneWidget);
    expect(tester.getRect(controls).top, greaterThanOrEqualTo(24));
    expect(
        tester.getRect(controls).bottom, lessThanOrEqualTo(size.height - 48));
    await tester.tap(controls);
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    expect(target.hitTestable(), findsOneWidget);
  }

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final large in [false, true]) {
        testWidgets(
            'short real viewer HUD ${locale.languageCode} scale=$scale large=$large',
            (tester) async {
          await open(tester, scale: scale, large: large, locale: locale);
          expect(tester.takeException(), isNull);
          final hud = find.byType(FractalControlsHud);
          final l10n = AppLocalizations.of(tester.element(hud))!;
          final target = large ? 56.0 : 48.0;
          final collapse = find.byTooltip(l10n.tooltipCollapse);
          await reveal(tester, collapse);
          final collapseBox = find
              .descendant(of: collapse, matching: find.byType(InkWell))
              .first;
          expect(tester.getSize(collapseBox), Size.square(target));
          expect(tester.getRect(collapseBox).top, greaterThanOrEqualTo(24));
          expect(tester.getRect(collapseBox).bottom, lessThanOrEqualTo(152));
          final slider =
              find.descendant(of: hud, matching: find.byType(Slider)).first;
          await reveal(tester, slider);
          expect(tester.getSize(slider).height, greaterThanOrEqualTo(target));
          expect(tester.getRect(slider).top, greaterThanOrEqualTo(24));
          expect(tester.getRect(slider).bottom, lessThanOrEqualTo(152));
          final randomize = find.widgetWithText(FilledButton, l10n.randomize);
          await reveal(tester, randomize);
          expect(
              tester.getSize(randomize).height, greaterThanOrEqualTo(target));
          expect(tester.getRect(randomize).top, greaterThanOrEqualTo(24));
          expect(tester.getRect(randomize).bottom, lessThanOrEqualTo(152));
          controller.updateZoom(2);
          final reset =
              find.widgetWithText(FilledButton, l10n.hudResetViewLabel);
          await reveal(tester, reset);
          await tester.tap(reset);
          await tester.pumpAndSettle();
          expect(controller.view.zoom, 1);
          await reveal(tester, collapse);
          await tester.tap(collapse);
          await tester.pumpAndSettle();
          expect(find.descendant(of: hud, matching: find.byType(Slider)),
              findsNothing);
          final surface = find.byKey(const ValueKey('controlsHudSurface'));
          expect(tester.getSize(surface).height, lessThan(176));
          expect(tester.getRect(surface).top, greaterThan(24));
          final pan = controller.view.pan.clone();
          await tester.dragFrom(const Offset(100, 45), const Offset(40, 0));
          await tester.pumpAndSettle();
          expect(controller.view.pan, isNot(pan),
              reason:
                  'Collapsed HUD must release the real renderer gesture region');
          final expand = find.byTooltip(l10n.tooltipExpand);
          await reveal(tester, expand);
          await tester.tap(expand);
          await tester.pumpAndSettle();
          final close = find.byTooltip(l10n.semanticCloseButton);
          await reveal(tester, close);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(find.byType(FractalControlsHud), findsNothing);
          final controls = find.byKey(const ValueKey('viewerControlsButton'));
          if (controls.evaluate().isEmpty) {
            final overflow = find.byKey(const ValueKey('viewerOverflowMenu'));
            await reveal(tester, overflow);
            await tester.tap(overflow);
            await tester.pumpAndSettle();
          }
          await reveal(tester, controls);
          await tester.tap(controls);
          await tester.pumpAndSettle();
          final back = find.byKey(const Key('viewerBackToCatalogButton'));
          expect(back, findsOneWidget);
          await reveal(tester, back);
          expect(tester.getSize(back), Size.square(target));
          expect(tester.getRect(back).top, greaterThanOrEqualTo(24));
          expect(tester.getRect(back).bottom, lessThanOrEqualTo(152));
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(find.text('Catalog route'), findsOneWidget);
          expect(find.byType(FractalViewerScreen), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('normal phone keeps the opaque bottom-aligned 55 percent HUD',
      (tester) async {
    await open(tester, size: const Size(360, 780));
    final surface = find.byKey(const ValueKey('controlsHudSurface'));
    final rect = tester.getRect(surface);
    expect(rect.left, 0);
    expect(rect.width, 360);
    expect(rect.bottom, 780);
    expect(rect.height, closeTo(429, 0.001));
    expect(tester.widget<Material>(surface).color!.a, 1);
    expect(find.byKey(const Key('viewerTitleChip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final large in [false, true]) {
        testWidgets(
            'short real More ${locale.languageCode} scale=$scale large=$large',
            (tester) async {
          controller.setKaleidoscopeEnabled(large);
          await open(tester,
              more: true, scale: scale, large: large, locale: locale);
          final sheet = find.byType(BottomSheet);
          final buttons = find.descendant(
              of: sheet, matching: find.byType(FloatingActionButtonWidget));
          expect(buttons.evaluate().length, greaterThanOrEqualTo(19));
          final actions = buttons.evaluate().map((e) => e.widget.key!).toList();
          expect(actions.first, const ValueKey('viewerOpenExportAction'));
          expect(actions.last, const ValueKey('viewerReportFractalFab'));
          for (final key in actions) {
            final action = find.byKey(key);
            await reveal(tester, action);
            final viewport = find
                .ancestor(
                    of: action, matching: find.byType(SingleChildScrollView))
                .first;
            final rect = tester.getRect(action);
            final visible = tester.getRect(viewport);
            expect(rect.height, greaterThanOrEqualTo(large ? 56 : 48));
            expect(rect.left, greaterThanOrEqualTo(visible.left));
            expect(rect.right, lessThanOrEqualTo(visible.right));
            // The shared sheet shell reserves its standard drag-handle and
            // safe-bottom spacing; its scroll body must still fit a full target.
            expect(
                visible.height, inInclusiveRange(large ? 56.0 : 48.0, 128.0));
            expect(rect.top, greaterThanOrEqualTo(visible.top - 0.01),
                reason: '$key $rect viewport=$visible');
            expect(rect.bottom, lessThanOrEqualTo(visible.bottom + 0.01),
                reason: '$key $rect viewport=$visible');
            expect(rect.top, greaterThanOrEqualTo(24));
            expect(rect.bottom, lessThanOrEqualTo(152));
          }
          final kaleidoscope = tester.widget<FloatingActionButtonWidget>(
              find.byKey(const ValueKey('viewerKaleidoscopeFab')));
          final labels = AppLocalizations.of(tester.element(sheet))!;
          expect(
              kaleidoscope.tooltip,
              large
                  ? labels.tooltipKaleidoscopeOn
                  : labels.tooltipKaleidoscopeOff);
          expect(kaleidoscope.selected, large);
          if (large)
            expect(find.byIcon(Icons.check_box_outlined), findsOneWidget);
          final close = find.byTooltip(
              MaterialLocalizations.of(tester.element(sheet))
                  .closeButtonTooltip);
          await reveal(tester, close);
          expect(tester.getSize(close), Size.square(large ? 56 : 48));
          expect(tester.getRect(close).top, greaterThanOrEqualTo(24));
          expect(tester.getRect(close).bottom, lessThanOrEqualTo(152));
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(find.byType(BottomSheet), findsNothing);
          final reopen = find.byKey(const ValueKey('viewerOverflowMenu'));
          await reveal(tester, reopen);
          await tester.tap(reopen);
          await tester.pumpAndSettle();
          final export = find.byKey(const ValueKey('viewerOpenExportAction'));
          await reveal(tester, export);
          await tester.tap(export);
          // More is activated in the short body. Destination-sheet layout is
          // separate shared-sheet scope; enlarge before its first frame.
          tester.view.physicalSize = const Size(1024, 1200);
          await tester.pumpAndSettle();
          expect(find.byType(ExportOptionsSheet), findsOneWidget);
          tester.state<NavigatorState>(find.byType(Navigator)).pop();
          await tester.pumpAndSettle();
          tester.view.physicalSize = const Size(320, 200);
          await tester.pumpAndSettle();
          final moreButton = find.byKey(const ValueKey('viewerOverflowMenu'));
          await reveal(tester, moreButton);
          await tester.tap(moreButton);
          await tester.pumpAndSettle();
          final report = find.byKey(const ValueKey('viewerReportFractalFab'));
          await reveal(tester, report);
          await tester.tap(report);
          tester.view.physicalSize = const Size(1024, 1200);
          await tester.pumpAndSettle();
          expect(find.byType(TextFormField), findsOneWidget);
          final l10n =
              AppLocalizations.of(tester.element(find.byType(TextFormField)))!;
          expect(find.text(l10n.reportDialogTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final height in [240.0, 312.0, 360.0, 480.0, 568.0]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final locale in const [Locale('en'), Locale('es')]) {
        testWidgets(
            'More boundary height=$height scale=$scale ${locale.languageCode}',
            (tester) async {
          await open(tester,
              size: Size(320, height),
              more: true,
              scale: scale,
              large: true,
              locale: locale);
          final sheet = find.byType(BottomSheet);
          final actions = find
              .descendant(
                  of: sheet, matching: find.byType(FloatingActionButtonWidget))
              .evaluate()
              .map((element) => element.widget.key!)
              .toList();
          expect(actions.length, greaterThanOrEqualTo(19));
          for (final key in actions) {
            final action = find.byKey(key);
            await reveal(tester, action);
            final viewport = find
                .ancestor(
                    of: action, matching: find.byType(SingleChildScrollView))
                .first;
            final bounds = tester.getRect(action);
            final visible = tester.getRect(viewport);
            expect(bounds.height, greaterThanOrEqualTo(56));
            expect(bounds.left, greaterThanOrEqualTo(visible.left));
            expect(bounds.right, lessThanOrEqualTo(visible.right));
            expect(bounds.top, greaterThanOrEqualTo(visible.top - .01),
                reason: '$key $bounds viewport=$visible');
            expect(bounds.bottom, lessThanOrEqualTo(visible.bottom + .01),
                reason: '$key $bounds viewport=$visible');
            expect(bounds.bottom, lessThanOrEqualTo(height - 48));
            expect(action.hitTestable(), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final size in [const Size(360, 780), const Size(320, 200)]) {
    for (final left in [true, false]) {
      for (final consumed in [false, true]) {
        testWidgets(
            'HUD $size and header reserve ${left ? 'left' : 'right'} ${consumed ? 'consumed padding' : 'gesture only'}',
            (tester) async {
          final sides =
              EdgeInsets.only(left: left ? 24 : 0, right: left ? 0 : 24);
          await open(
            tester,
            size: size,
            scale: size.height == 200 ? 3 : 1,
            large: size.height == 200,
            gestures: consumed ? EdgeInsets.zero : sides,
            viewPadding: consumed
                ? sides.copyWith(top: 24, bottom: 48)
                : const EdgeInsets.only(top: 24, bottom: 48),
          );
          final back = find.byKey(const Key('viewerBackToCatalogButton'));
          final title = find.byKey(const Key('viewerTitleChip'));
          final hud = find.byType(FractalControlsHud);
          final l10n = AppLocalizations.of(tester.element(hud))!;
          for (final control in [
            back,
            if (size.height != 200) title,
            find.descendant(of: hud, matching: find.byType(Slider)).first,
            find.byTooltip(l10n.tooltipCollapse),
            find.widgetWithText(FilledButton, l10n.randomize),
          ]) {
            await reveal(tester, control);
            final rect = tester.getRect(control);
            expect(rect.left, greaterThanOrEqualTo(left ? 24 : 0));
            expect(rect.right, lessThanOrEqualTo(size.width - (left ? 0 : 24)));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
