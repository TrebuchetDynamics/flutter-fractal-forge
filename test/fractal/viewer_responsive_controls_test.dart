import 'package:flutter/material.dart';
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
    final controls = find.byKey(const ValueKey('viewerControlsButton'));
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
