import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/permission_test_harness.dart';
import 'package:vector_math/vector_math.dart' show Vector2, Vector3;

class _LooperExportService extends ExportService {
  _LooperExportService({
    this.pickerDelay = Duration.zero,
    this.pickerThrows = false,
    this.shareThrows = false,
    this.captureWidth = 2,
    this.captureHeight = 2,
  });

  final Duration pickerDelay;
  final bool pickerThrows;
  final bool shareThrows;
  final int captureWidth;
  final int captureHeight;
  int saveCalls = 0;
  Uint8List? savedBytes;
  String? sharedText;

  @override
  Future<bool> chooseLinuxExportDirectory() async {
    if (pickerDelay > Duration.zero) await Future<void>.delayed(pickerDelay);
    if (pickerThrows) throw StateError('picker unavailable');
    return true;
  }

  @override
  Future<Uint8List> capturePng(
    GlobalKey key, {
    double pixelRatio = 1.0,
  }) async =>
      Uint8List.fromList(
          img.encodePng(img.Image(width: captureWidth, height: captureHeight)));

  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    saveCalls++;
    savedBytes = bytes;
    return File('/tmp/$filename');
  }

  @override
  Future<void> shareFile(File file, {String? text}) async {
    sharedText = text;
    if (shareThrows) throw StateError('share unavailable');
  }
}

class _ScreenSizeExportService extends ExportService {
  double? logicalWidth;
  double? logicalHeight;
  double? physicalScreenWidth;
  double? physicalScreenHeight;

  @override
  Future<bool> chooseLinuxExportDirectory() async => true;

  @override
  Future<ExportResult> exportWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required String fractalType,
    required Map<String, Object> parameters,
    double? physicalScreenWidth,
    double? physicalScreenHeight,
    void Function(double progress)? onProgress,
  }) async {
    logicalWidth = screenWidth;
    logicalHeight = screenHeight;
    this.physicalScreenWidth = physicalScreenWidth;
    this.physicalScreenHeight = physicalScreenHeight;
    return ExportResult(
      file: File('/tmp/screen.png'),
      filename: 'screen.png',
      format: ExportFormat.png,
      width: 1080,
      height: 1920,
      fileSize: 0,
    );
  }

  @override
  Future<void> saveExportResult(ExportResult result) async {}
}

class _FallbackScreenSizeExportService extends ExportService {
  double? capturedPixelRatio;
  (int, int)? resizedDimensions;

  @override
  Future<bool> chooseLinuxExportDirectory() async => true;

  @override
  Future<ExportResult> exportWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    double? physicalScreenWidth,
    double? physicalScreenHeight,
    required String fractalType,
    required Map<String, Object> parameters,
    void Function(double progress)? onProgress,
  }) async {
    throw StateError('force fallback');
  }

  @override
  Future<Uint8List> capturePng(
    GlobalKey key, {
    double pixelRatio = 1.0,
  }) async {
    capturedPixelRatio = pixelRatio;
    return Uint8List.fromList(<int>[1]);
  }

  @override
  Uint8List resizePngToTargetDimensions(
    Uint8List pngBytes, {
    required int width,
    required int height,
    String? quoteText,
  }) {
    resizedDimensions = (width, height);
    return pngBytes;
  }

  @override
  Future<ExportResult> saveExportBytes(
    Uint8List bytes, {
    required String filename,
    required ExportFormat format,
    required int width,
    required int height,
  }) async {
    return ExportResult(
      file: File('/tmp/$filename'),
      filename: filename,
      format: format,
      width: width,
      height: height,
      fileSize: bytes.length,
    );
  }
}

void main() {
  group('FractalViewerScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late RendererSettingsService rendererSettings;
    late HistoryStore historyStore;
    late HistoryProvider historyProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      installDenyAllPermissionsHandler();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());
      historyStore = await HistoryStore.create();
      historyProvider = HistoryProvider(store: historyStore);
    });

    tearDown(() {
      historyProvider.dispose();
      controller.dispose();
      rendererSettings.dispose();
    });

    Widget buildTestWidget({
      CatalogFamily catalogFamily = CatalogFamily.core,
      Locale locale = const Locale('en'),
      ExportService? exportService,
    }) {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          ChangeNotifierProvider.value(value: rendererSettings),
          ChangeNotifierProvider.value(value: historyProvider),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FractalViewerScreen(
            catalogFamily: catalogFamily,
            exportService: exportService,
          ),
        ),
      );
    }

    testWidgets('displays current module name in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('does not show renderer status chip', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);
      expect(find.byKey(const Key('viewerStatusChipText')), findsNothing);
    });

    testWidgets('back FAB is not shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('fullscreen FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Fullscreen view'), findsOneWidget);
    });

    testWidgets('fractal music FAB is immediately visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final music = find.byKey(const ValueKey('viewerFractalMusicButton'));
      expect(music, findsOneWidget);
      final rect = tester.getRect(music);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(600));
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('FAB column stays on-screen and scrolls on short viewports',
        (tester) async {
      // Simulate a short viewport (e.g. landscape phone / small web window)
      // where the stacked FAB column is taller than the available height.
      tester.view.physicalSize = const Size(400, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The stacked column must not overflow its parent.
      expect(tester.takeException(), isNull);

      // The top-most quick-control FAB must stay within the viewport instead of
      // being pushed above the top edge (the pre-fix overflow symptom).
      final fullscreen = find.byKey(const ValueKey('viewerFullscreenButton'));
      expect(fullscreen, findsOneWidget);
      expect(tester.getRect(fullscreen).top, greaterThanOrEqualTo(0.0),
          reason: 'top FAB was pushed off the top of the viewport');

      // The scroll container is height-bounded (so it can actually scroll)
      // rather than expanding to its full natural content height.
      final column = find.byKey(const ValueKey('viewerFabColumn'));
      expect(column, findsOneWidget);
      expect(tester.getSize(column).height, lessThan(360.0),
          reason: 'FAB column is unbounded and cannot scroll');
    });

    testWidgets('random fractal FAB switches module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, equals('mandelbrot'));

      final randomButton = find.byKey(const ValueKey('viewerRandomButton'));
      await tester.ensureVisible(randomButton);
      await tester.pumpAndSettle();
      await tester.tap(randomButton);
      await tester.pumpAndSettle();

      expect(controller.module.id, isNot(equals('mandelbrot')));
      final paletteParam = controller.module.parameters.firstWhere(
        (param) => param.id == 'colorScheme',
      );
      expect(
        controller.params['colorScheme'],
        isNot(paletteParam.defaultValue),
        reason: 'Random fractal must also choose a new palette',
      );

      // Let delayed FAB fade-in timers complete before teardown.
      await tester.pump(const Duration(milliseconds: 400));

      // Drain/cancel pending history debounce timer to keep test harness clean.
      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('camera FAB is not shown (feature removed)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_rounded), findsNothing);
    });

    testWidgets('fullscreen FAB collapses controls and restores them',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Fullscreen view'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);

      await tester.tap(find.byTooltip('Fullscreen view'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Exit fullscreen view'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);

      await tester.tap(find.byTooltip('Exit fullscreen view'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);
    });

    testWidgets('export FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('viewerExportButton')), findsOneWidget);
    });

    testWidgets('screen export receives the view physical pixel dimensions',
        (tester) async {
      tester.view.devicePixelRatio = 2.625;
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.reset);
      final exportService = _ScreenSizeExportService();

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pumpAndSettle();

      expect(exportService.logicalWidth, closeTo(1080 / 2.625, 0.001));
      expect(exportService.logicalHeight, closeTo(1920 / 2.625, 0.001));
      expect(exportService.physicalScreenWidth, 1080);
      expect(exportService.physicalScreenHeight, 1920);
    });

    testWidgets('fallback screen export keeps the physical pixel dimensions',
        (tester) async {
      tester.view.devicePixelRatio = 2.625;
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.reset);
      final exportService = _FallbackScreenSizeExportService();

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pumpAndSettle();

      expect(exportService.capturedPixelRatio, closeTo(2.625, 0.0001));
      expect(exportService.resizedDimensions, (1080, 1920));
    });

    testWidgets('performance family route hides core viewer chrome',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(catalogFamily: CatalogFamily.performance),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
      expect(find.byKey(const ValueKey('viewerRandomButton')), findsNothing);
      expect(
          find.byKey(const ValueKey('viewerRandomParamsButton')), findsNothing);
      expect(
          find.byKey(const ValueKey('viewerFractalMusicButton')), findsNothing);
      expect(find.byTooltip('Controls'), findsNothing);
      expect(find.text('Mandelbrot'), findsNothing);

      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('displays fractal renderer surface', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Test surface is rendered in test mode
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('updates title when module changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays Julia module correctly', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays Burning Ship module correctly', (tester) async {
      controller.selectModule(registry.byId('burning_ship'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
    });

    testWidgets('displays Phoenix module correctly', (tester) async {
      controller.selectModule(registry.byId('phoenix'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phoenix'), findsOneWidget);
    });

    testWidgets('displays Mandelbulb module correctly', (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('has scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('controls FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('viewerRandomParamsButton')),
          findsOneWidget);
    });

    testWidgets('controls FAB opens controls sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('viewerRandomParamsButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
    });

    testWidgets('controls HUD supports modules without core params',
        (tester) async {
      controller.selectModule(registry.byId('test_minimal'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('viewerRandomParamsButton')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Fluid mode'), findsOneWidget);
      expect(find.text('Iterations'), findsNothing);
      expect(find.text('Bailout'), findsNothing);
    });

    testWidgets('keyboard arrow keys pan view', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialX = controller.view.pan.x;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.pan.x, greaterThan(initialX));
    });

    testWidgets('keyboard plus and minus keys adjust zoom', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialZoom = controller.view.zoom;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.equal);
      await tester.pump();
      final zoomedIn = controller.view.zoom;

      expect(zoomedIn, greaterThan(initialZoom));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.minus);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.zoom, lessThan(zoomedIn));
    });

    testWidgets('keyboard R resets view state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      controller.updatePan(Vector2(0.5, -0.25));
      controller.updateZoom(4.0);
      await tester.pump();

      expect(controller.view.zoom, equals(4.0));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.zoom, equals(1.0));
      expect(controller.view.pan.x, equals(0.0));
      expect(controller.view.pan.y, equals(0.0));
    });

    testWidgets(
        'keyboard arrow keys pan in screen-relative direction on a rotated '
        'view', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // A 90-degree view rotation swaps which world axis "screen-right"
      // maps to. Pressing the right arrow must still pan the *screen*
      // rightward, i.e. follow the rotation, not silently move along the
      // unrotated world x-axis (regression: pans in the wrong direction
      // once the view is rotated).
      controller.updateRotation(Vector3(0, 0, math.pi / 2));
      final initialPan = controller.view.pan;
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.pan.x, closeTo(initialPan.x, 1e-9));
      expect(controller.view.pan.y, lessThan(initialPan.y));
    });

    Future<double> exportLooper(
      WidgetTester tester,
      _LooperExportService exportService, {
      bool previewBeforeExport = false,
      bool settleAfterExport = true,
    }) async {
      await tester.pumpWidget(buildTestWidget(
        locale: const Locale('es'),
        exportService: exportService,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('viewerLooperButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('looperSetAButton')));
      controller.updateZoom(2);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('looperSetBButton')));
      await tester.drag(
        find.byKey(const ValueKey('looperDurationSlider')),
        const Offset(-500, 0),
      );
      await tester.pump();
      if (previewBeforeExport) {
        await tester.tap(find.byKey(const ValueKey('looperPreviewButton')));
        await tester.pump();
      }
      final zoomAtExport = controller.view.zoom;
      await tester.tap(find.byKey(const ValueKey('looperExportGifButton')));
      if (settleAfterExport) await tester.pumpAndSettle();
      return zoomAtExport;
    }

    testWidgets(
        'looper export localizes feedback and shares the pre-export view',
        (tester) async {
      final exportService = _LooperExportService();
      await exportLooper(tester, exportService);

      expect(exportService.saveCalls, 1);
      final gif = img.decodeGif(exportService.savedBytes!);
      expect(gif, isNotNull);
      expect(gif!.numFrames, 8);
      expect(gif.frames.every((frame) => frame.frameDuration == 120), isTrue);
      expect(find.text('GIF en bucle exportado'), findsOneWidget);
      expect(find.text('Looper GIF exported'), findsNothing);
      final sharedUrl = exportService.sharedText!
          .split('\n')
          .firstWhere((line) => line.startsWith('https://'));
      expect(Uri.parse(sharedUrl).queryParameters['z'], '2');
      historyProvider.cancelPendingRecord();
    });

    testWidgets('looper GIF caps its longest side at 480 pixels',
        (tester) async {
      final exportService = _LooperExportService(
        captureWidth: 600,
        captureHeight: 1000,
      );
      await exportLooper(tester, exportService);

      final gif = img.decodeGif(exportService.savedBytes!)!;
      expect(gif.width, 288);
      expect(gif.height, 480);
      historyProvider.cancelPendingRecord();
    });

    testWidgets('looper keeps a completed save when sharing fails',
        (tester) async {
      final exportService = _LooperExportService(shareThrows: true);
      await exportLooper(tester, exportService);

      expect(exportService.saveCalls, 1);
      expect(
        find.text(
          'GIF en bucle guardado. No se abrió compartir; comparte el archivo guardado manualmente.',
        ),
        findsOneWidget,
      );
      historyProvider.cancelPendingRecord();
    });

    testWidgets('looper reports a directory picker failure', (tester) async {
      final exportService = _LooperExportService(pickerThrows: true);
      await exportLooper(tester, exportService);

      expect(tester.takeException(), isNull);
      expect(exportService.saveCalls, 0);
      expect(
        find.textContaining('Error al exportar el GIF en bucle'),
        findsOneWidget,
      );
      expect(find.textContaining('Exportación de video fallida'), findsNothing);
      historyProvider.cancelPendingRecord();
    });

    testWidgets('looper stops preview when the directory picker fails',
        (tester) async {
      final exportService = _LooperExportService(
        pickerDelay: const Duration(milliseconds: 200),
        pickerThrows: true,
      );
      final zoomAtExport = await exportLooper(
        tester,
        exportService,
        previewBeforeExport: true,
        settleAfterExport: false,
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.view.zoom, zoomAtExport);
      historyProvider.cancelPendingRecord();
    });

    testWidgets('looper export restores the state visible before the picker',
        (tester) async {
      final exportService = _LooperExportService(
        pickerDelay: const Duration(milliseconds: 200),
      );
      final zoomAtExport = await exportLooper(
        tester,
        exportService,
        previewBeforeExport: true,
      );

      expect(controller.view.zoom, zoomAtExport);
      historyProvider.cancelPendingRecord();
    });

    testWidgets('works with all modules', (tester) async {
      // Many screens include continuous animations (shader time, UI pulses, etc.).
      // `pumpAndSettle` can therefore time out even when the UI is correct.
      // For this smoke test we only need a couple of frames.
      for (final module in registry.modules) {
        controller.selectModule(module);
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Basic sanity: the screen should build and not throw.
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Avoid long-running debounce carryover between module swaps.
        historyProvider.cancelPendingRecord();
      }

      // Ensure pending async work is drained before teardown.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      historyProvider.cancelPendingRecord();
    });
  });
}
