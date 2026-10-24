import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart';
import 'package:provider/provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../a11y/shared/main_app_a11y_harness.dart';

TestDefaultBinaryMessenger get testerMessenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

class _DocumentsPathProvider extends PathProviderPlatform {
  _DocumentsPathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  group('HomeScreen via FlutterFractalsApp', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    Widget buildTestWidget() => harness.buildApp();

    Future<DeepLinkService> platformLinks() async {
      const channel = MethodChannel('com.fractalforge/deeplink');
      testerMessenger.setMockMethodCallHandler(channel, (_) async => null);
      final service = DeepLinkService();
      await service.initialize();
      addTearDown(() {
        service.dispose();
        testerMessenger.setMockMethodCallHandler(channel, null);
      });
      return service;
    }

    Future<void> deliverLink(WidgetTester tester, String query) async {
      await testerMessenger.handlePlatformMessage(
        'com.fractalforge/deeplink',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('onDeepLink', 'fractalforge://view?$query'),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
    }

    Widget linkedApp(DeepLinkService links, ViewerSessionStore store) =>
        FlutterFractalsApp(
          presetStore: harness.presetStore,
          accessibilityService: harness.accessibilityService,
          rendererSettingsService: harness.rendererSettingsService,
          deepLinkService: links,
          viewerSessionStore: store,
          skipSplash: true,
          locale: const Locale('en'),
        );

    testWidgets('repeated platform links reuse the Home-owned viewer',
        (tester) async {
      final links = await platformLinks();
      final store = await ViewerSessionStore.create();
      await tester.pumpWidget(linkedApp(links, store));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mandelbrot');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      final catalog = tester.state(find.byType(FractalCatalogScreen));
      final scroll = tester
          .state<ScrollableState>(find
              .descendant(
                of: find.byType(FractalCatalogScreen),
                matching: find.byType(Scrollable),
              )
              .last)
          .position;
      scroll.jumpTo(80);
      await tester.pumpAndSettle();
      final offset = scroll.pixels;
      expect(offset, greaterThan(0));

      for (final entry in ['link', 'catalog', 'reopen']) {
        if (entry == 'catalog') {
          await tester.tap(find.byKey(
            const Key('catalogModuleCard_core.mandelbrot'),
          ));
          await tester.pumpAndSettle();
        } else {
          await deliverLink(tester, 'type=mandelbrot&zoom=3');
        }
        final viewerState = tester.state(find.byType(FractalViewerScreen));
        final controller = tester
            .element(find.byType(FractalViewerScreen))
            .read<FractalController>();
        await deliverLink(tester, 'type=julia&zoom=7&iterations=123');
        await deliverLink(tester, 'type=mandelbrot&zoom=9');
        expect(find.byType(FractalViewerScreen, skipOffstage: false),
            findsOneWidget);
        expect(
            tester.state(find.byType(FractalViewerScreen)), same(viewerState));
        expect(
            tester
                .widget<FractalViewerScreen>(find.byType(FractalViewerScreen))
                .catalogFamily,
            CatalogFamily.core);
        expect(controller.module.id, 'mandelbrot');
        expect(controller.view.zoom, 9);
        expect(store.load()!.viewerActive, isTrue);
        await tester.tap(find.byKey(const Key('viewerBackToCatalogButton')));
        await tester.pumpAndSettle();
        expect(find.byType(FractalViewerScreen, skipOffstage: false),
            findsNothing);
        expect(store.load()!.viewerActive, isFalse);
        expect(tester.state(find.byType(FractalCatalogScreen)), same(catalog));
        expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Mandelbrot');
        expect(scroll.pixels, offset);
      }
    });

    testWidgets('a platform link wins before a restored viewer first builds',
        (tester) async {
      final links = await platformLinks();
      final store = await ViewerSessionStore.create();
      await tester.pumpWidget(linkedApp(links, store));
      await tester.pumpAndSettle();
      await deliverLink(tester, 'type=mandelbrot&zoom=3');
      final interrupted = store.load()!;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await store.save(interrupted);
      // This frame pushes restoration's route, but has not built its viewer.
      await tester.pumpWidget(linkedApp(links, store));
      await deliverLink(tester, 'type=julia&zoom=7');
      final controller = tester
          .element(find.byType(FractalViewerScreen))
          .read<FractalController>();
      expect(controller.module.id, 'julia');
      expect(controller.view.zoom, 7);
      expect(find.byType(FractalViewerScreen, skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('covered routes and active exports reject links until retry',
        (tester) async {
      final links = await platformLinks();
      final store = await ViewerSessionStore.create();
      await tester.pumpWidget(linkedApp(links, store));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('homeSettingsButton')));
      await tester.pumpAndSettle();
      await deliverLink(tester, 'type=julia&zoom=7');
      expect(find.text('Settings'), findsOneWidget);
      expect(
          find.byType(FractalViewerScreen, skipOffstage: false), findsNothing);
      final navigator =
          tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pop();
      await tester.pumpAndSettle();
      await deliverLink(tester, 'type=mandelbrot&zoom=3');
      final viewerContext = tester.element(find.byType(FractalViewerScreen));
      final controller = viewerContext.read<FractalController>();
      final before = Map<String, Object>.from(controller.params);
      unawaited(showDialog<void>(
        context: viewerContext,
        builder: (_) => const AlertDialog(title: Text('Blocking operation')),
      ));
      await tester.pumpAndSettle();
      await deliverLink(tester, 'type=julia&zoom=7');
      expect(find.text('Blocking operation'), findsOneWidget);
      expect(controller.module.id, 'mandelbrot');
      expect(controller.view.zoom, 3);
      expect(controller.params, before);
      navigator.pop();
      ScaffoldMessenger.of(viewerContext).clearSnackBars();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      final sheet = tester.state(find.byType(ExportOptionsSheet));
      await deliverLink(tester, 'type=julia&zoom=7');
      expect(tester.state(find.byType(ExportOptionsSheet)), same(sheet));
      expect(controller.module.id, 'mandelbrot');
      expect(controller.params, before);
      expect(controller.view.zoom, 3);
      navigator.pop();
      ScaffoldMessenger.of(viewerContext).clearSnackBars();
      await tester.pumpAndSettle();
      if (Platform.isLinux) {
        final previousPathProvider = PathProviderPlatform.instance;
        final directory = await tester
            .runAsync(() => Directory.systemTemp.createTemp('viewer-picker-'));
        PathProviderPlatform.instance = _DocumentsPathProvider(directory!.path);
        final pickerEntered = Completer<void>();
        final pickerResult = Completer<String?>();
        const pickerChannel = MethodChannel('plugins.flutter.io/file_selector');
        testerMessenger.setMockMethodCallHandler(pickerChannel, (call) async {
          expect(call.method, 'getDirectoryPath');
          pickerEntered.complete();
          return pickerResult.future;
        });
        addTearDown(() async {
          if (!pickerResult.isCompleted) pickerResult.complete(null);
          testerMessenger.setMockMethodCallHandler(pickerChannel, null);
          PathProviderPlatform.instance = previousPathProvider;
          await directory.delete(recursive: true);
        });
        await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Share image'));
        // Drain filesystem preflight, stopping at the deferred native picker.
        for (var i = 0; i < 20 && !pickerEntered.isCompleted; i++) {
          await tester.runAsync(() => directory.exists());
          await tester.pump();
        }
        expect(pickerEntered.isCompleted, isTrue);
        await tester.pumpAndSettle();
        expect(ExportCoordinator.shared.isBusy, isFalse);
        await deliverLink(tester, 'type=julia&zoom=7');
        expect(controller.module.id, 'mandelbrot');
        expect(controller.view.zoom, 3);
        pickerResult.complete(null);
        await tester.pumpAndSettle();
      }
      final release = Completer<void>();
      final exporting =
          ExportCoordinator.shared.run(ExportKind.image, (token) async {
        await release.future;
        expect(token.isCancelled, isFalse);
      });
      await deliverLink(tester, 'type=julia&zoom=7');
      expect(ExportCoordinator.shared.isBusy, isTrue);
      expect(controller.module.id, 'mandelbrot');
      expect(controller.view.zoom, 3);
      expect(
          find.text('Finish the current operation, then open the link again.'),
          findsOneWidget);
      release.complete();
      await exporting;
      await deliverLink(tester, 'type=julia&zoom=7');
      expect(controller.module.id, 'julia');
      expect(controller.view.zoom, 7);
      expect(find.byType(FractalViewerScreen, skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('viewer push and pop respect each reduced motion source',
        (tester) async {
      addTearDown(tester
          .binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final links = await platformLinks();
      final store = await ViewerSessionStore.create();
      for (final source in ['normal', 'system', 'app']) {
        tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: source == 'system');
        await harness.accessibilityService.setReducedMotion(source == 'app');
        await tester.pumpWidget(linkedApp(links, store));
        await tester.pumpAndSettle();
        await tester.tap(find
            .byWidgetPredicate((widget) =>
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>)
                    .value
                    .startsWith('catalogModuleCard_'))
            .first);
        await tester.pumpAndSettle();
        final route = ModalRoute.of(
          tester.element(find.byType(FractalViewerScreen)),
        )!;
        final expected =
            source == 'normal' ? AppAnimations.slow : Duration.zero;
        expect(route.transitionDuration, expected);
        final reverseDuration = source == 'normal'
            ? const Duration(milliseconds: 300)
            : Duration.zero;
        expect(route.reverseTransitionDuration, reverseDuration);
        await tester.tap(find.byKey(const Key('viewerBackToCatalogButton')));
        await tester.pumpAndSettle();
        await deliverLink(tester, 'type=mandelbrot&zoom=3');
        final linkRoute = ModalRoute.of(
          tester.element(find.byType(FractalViewerScreen)),
        )!;
        final linkDuration =
            source == 'normal' ? AppAnimations.normal : Duration.zero;
        expect(linkRoute.transitionDuration, linkDuration);
        expect(linkRoute.reverseTransitionDuration, reverseDuration);
        await tester.tap(find.byKey(const Key('viewerBackToCatalogButton')));
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });

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
        expect(tester.getSize(back).height, greaterThanOrEqualTo(48));
        if (mode == 'normal') {
          Focus.of(tester.element(
            find.descendant(of: back, matching: find.byType(Icon)),
          )).requestFocus();
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
