import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/main.dart';
import '../a11y/shared/main_app_a11y_harness.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/number_wall_exact_renderer.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('startup without a verified wall reports pending and failure',
      (tester) async {
    final wall = ModuleRegistry().byId('number_wall');
    for (final entry in const [
      ('561', Locale('en'), 'Number Wall settings could not be verified.'),
      (
        '170141183460469231731687303715884105727',
        Locale('es'),
        'No se pudieron verificar los parámetros del muro numérico.'
      ),
    ]) {
      final harness = MainAppA11yHarness();
      await harness.setUp();
      final store = await ViewerSessionStore.create();
      await store.save(ViewerSessionSnapshot(
          moduleId: wall.id,
          params: {...wall.defaultPreset.params, 'prime': entry.$1},
          view: wall.defaultPreset.view,
          transparentBackground: false,
          rotationLocked: false,
          glowEnabled: false,
          glowSigma: 1,
          glowIntensity: 1,
          fluidModeEnabled: false,
          fluidStrength: 1,
          kaleidoscopeEnabled: false,
          kaleidoscopeSectors: 6,
          kaleidoscopeMirror: false,
          kaleidoscopeRotation: 0,
          kaleidoscopeMirrorMode: 0,
          controlsVisible: true,
          fullscreenUnobtrusive: false,
          viewerActive: true));
      await tester.pumpWidget(FlutterFractalsApp(
          presetStore: harness.presetStore,
          accessibilityService: harness.accessibilityService,
          rendererSettingsService: harness.rendererSettingsService,
          viewerSessionStore: store,
          locale: entry.$2));
      expect(find.byKey(const Key('numberWallRestoreStatus')), findsOneWidget);
      await tester.pumpAndSettle();
      final controller = tester
          .element(find.byType(FractalCatalogScreen))
          .read<FractalController>();
      expect(controller.module.id, 'mandelbrot');
      expect(controller.numberWallGrid, isNull);
      expect(find.byKey(const Key('fractalViewerRoot')), findsNothing);
      expect(find.text(entry.$3), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
  testWidgets('deep-link navigation and visual flags wait for certified walls',
      (tester) async {
    final harness = MainAppA11yHarness();
    await harness.setUp();
    const channel = MethodChannel('com.fractalforge/deeplink');
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    final links = DeepLinkService();
    await links.initialize();
    addTearDown(links.dispose);
    await tester.pumpWidget(FlutterFractalsApp(
        presetStore: harness.presetStore,
        accessibilityService: harness.accessibilityService,
        rendererSettingsService: harness.rendererSettingsService,
        deepLinkService: links,
        locale: const Locale('en')));
    await tester.pumpAndSettle();
    final controller = tester
        .element(find.byType(FractalCatalogScreen))
        .read<FractalController>();
    final wall = controller.registry.byId('number_wall');
    for (final prime in ['561', '97']) {
      final uri = DeepLinkService.buildUri(
          moduleId: wall.id,
          params: {
            ...wall.defaultPreset.params,
            'prime': prime,
            'rows': 4,
            'columns': 16
          },
          view: wall.defaultPreset.view,
          glowEnabled: true);
      await tester.runAsync(() async {
        final delivered = Completer<void>();
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            channel.name,
            const StandardMethodCodec()
                .encodeMethodCall(MethodCall('onDeepLink', uri.toString())),
            (_) => delivered.complete());
        await delivered.future;
      });
      for (var i = 0; i < 200 && controller.numberWallPending; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(controller.numberWallPending, isFalse);
      await tester.pumpAndSettle();
      if (prime == '561') {
        expect(find.byKey(const Key('fractalViewerRoot')), findsNothing);
        expect(controller.module.id, 'mandelbrot');
        expect(controller.glowEnabled, isFalse);
      } else {
        expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
        expect(controller.numberWallGrid!.prime, BigInt.from(97));
        expect(controller.glowEnabled, isTrue);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets('Number Walls hides unsupported effects on both control surfaces',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final wall = controller.registry.byId('number_wall');
    controller.setFluidModeEnabled(true);
    await tester.runAsync(() => controller.loadState(
        module: wall,
        params: {...wall.defaultPreset.params, 'rows': 4, 'columns': 16},
        view: wall.defaultPreset.view));
    for (final surface in const [
      FractalControlsHud(),
      FractalControlsSheet()
    ]) {
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: surface))));
      await tester.pumpAndSettle();
      expect(find.text('Fluid intensity'), findsNothing);
      expect(find.text('Kaleidoscope'), findsNothing);
      expect(find.text('Glow'), findsNothing);
    }
  });
  testWidgets(
      'Number Walls controls stay accessible in EN/ES at required widths',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final wall = controller.registry.byId('number_wall');
    await tester.runAsync(() => controller.loadState(
        module: wall,
        params: {...wall.defaultPreset.params, 'rows': 4, 'columns': 16},
        view: wall.defaultPreset.view));
    final semantics = tester.ensureSemantics();
    for (final width in [320.0, 768.0, 1440.0]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      for (final locale in [const Locale('en'), const Locale('es')]) {
        await tester.pumpWidget(ChangeNotifierProvider.value(
            value: controller,
            child: MaterialApp(
              locale: locale,
              theme: ThemeData.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                  data: MediaQueryData(
                      size: Size(width, 900),
                      textScaler: TextScaler.linear(2),
                      highContrast: true,
                      disableAnimations: true),
                  child: const Scaffold(body: FractalControlsHud())),
            )));
        await tester.pumpAndSettle();
        final field = find.byType(TextField);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.tap(field);
        await tester.enterText(field, '101');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(controller.params['prime'], '101');
        final apply = find.byTooltip(locale.languageCode == 'en'
            ? 'Apply verified prime'
            : 'Aplicar primo verificado');
        expect(tester.getSize(apply).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(apply).height, greaterThanOrEqualTo(48));
        final foreground = find.text(locale.languageCode == 'en'
            ? 'Nonzero colour'
            : 'Color de no ceros');
        await tester.ensureVisible(foreground);
        await tester.tap(foreground);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '123456');
        await tester
            .tap(find.text(locale.languageCode == 'en' ? 'Apply' : 'Aplicar'));
        await tester.pumpAndSettle();
        expect(controller.params['foregroundColor'], 0x123456);
        expect(tester.takeException(), isNull, reason: '$locale width=$width');
      }
    }
    semantics.dispose();
  });
  testWidgets(
      'exact displays share cell geometry and capture only complete fields',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final module = controller.registry.byId('number_wall');
    await tester.runAsync(() => controller.loadState(
        module: module,
        params: {
          ...module.defaultPreset.params,
          'rows': 4,
          'columns': 16,
          'source': 'squares',
          'prime': '3'
        },
        view: module.defaultPreset.view));
    await tester.runAsync(() => ui.FragmentProgram.fromAsset(
        'shaders/number_theory/number_wall_gpu.frag'));
    final key = GlobalKey();
    Future<List<int>> render(RendererBackendMode mode) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(ChangeNotifierProvider.value(
            value: controller,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                  body: Center(
                      child: SizedBox(
                          width: 160,
                          height: 80,
                          child: NumberWallExactRenderer(
                              boundaryKey: key,
                              backendMode: mode,
                              showIndicator: false)))),
            )));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      for (var i = 0; i < 40; i++) {
        await tester.pump();
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)));
        if (key.currentContext != null) break;
      }
      await tester.pump();
      expect(key.currentContext, isNotNull);
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final bytes =
              await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          return bytes!.buffer.asUint8List().toList();
        } finally {
          image.dispose();
        }
      }))!;
    }

    final canvas = await render(RendererBackendMode.cpuOnly);
    final sampler = await render(RendererBackendMode.gpuOnly);
    expect(sampler, canvas);
    // First visible row: s[64]=1, s[66]=0 modulo 3, no half-cell shift.
    expect(canvas.sublist((10 * 160 + 5) * 4, (10 * 160 + 5) * 4 + 4),
        [32, 40, 59, 255]);
    expect(canvas.sublist((10 * 160 + 25) * 4, (10 * 160 + 25) * 4 + 4),
        [244, 201, 93, 255]);
    await tester.tapAt(
        tester.getTopLeft(find.byKey(const Key('numberWallExactPlot'))) +
            const Offset(25, 10));
    await tester.pump();
    expect(find.textContaining('m=0, n=66, p=3, residue=0'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.textContaining('m=0, n=67, p=3, residue=1'), findsOneWidget);
    controller.updateParam('colorMode', 1);
    controller.updateParam('colorScheme', 3);
    controller.updateParam('zeroColor', 0xffaa00);
    controller.updateParam('backgroundColor', 0x112233);
    controller.updateParam('showGrid', true);
    final styledCanvas = await render(RendererBackendMode.cpuOnly);
    expect(await render(RendererBackendMode.gpuOnly), styledCanvas);
    expect(styledCanvas, isNot(canvas));
    final pending = controller
        .applyNumberWallPrime('170141183460469231731687303715884105727');
    await tester.pump();
    expect(key.currentContext, isNull,
        reason: 'pending state is never a cache-ready frame');
    controller.cancelNumberWallRequest();
    await tester.pump(const Duration(milliseconds: 1));
    expect(await pending, NumberWallPrimeStatus.cancelled);
  });
  testWidgets('viewer HUD applies custom primes and retains invalid edits',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    controller.selectModule(controller.registry.byId('number_wall'),
        animate: false);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FractalControlsHud()),
      ),
    ));
    final editor = find.byType(TextField);
    expect(editor, findsOneWidget);
    await tester.ensureVisible(editor);
    await tester.enterText(editor, '97');
    await tester.ensureVisible(find.byTooltip('Apply verified prime'));
    await tester.tap(find.byTooltip('Apply verified prime'));
    await tester.pumpAndSettle();
    expect(controller.params['prime'], '97');
    await tester.enterText(editor, '561');
    await tester.ensureVisible(find.byTooltip('Apply verified prime'));
    await tester.tap(find.byTooltip('Apply verified prime'));
    await tester.pumpAndSettle();
    expect(controller.params['prime'], '97');
    expect(
        find.text('Invalid prime; previous value retained.'), findsOneWidget);
  });
  testWidgets('number wall opens the exact grid renderer without escape-time',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    controller.selectModule(controller.registry.byId('number_wall'),
        animate: false);

    await tester.pumpWidget(
      ChangeNotifierProvider<FractalController>.value(
        value: controller,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: FractalRenderer(
                  overrideChild: Text('Wrong generic CPU surface'))),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('numberWallExactPlot')), findsOneWidget);
    expect(find.textContaining('exact finite-field wall'), findsNothing);
    controller.dispose();
  });
}
