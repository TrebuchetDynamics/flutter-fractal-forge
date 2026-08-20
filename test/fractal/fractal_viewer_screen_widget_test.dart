import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/wallpaper_service.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/permission_test_harness.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

class _LooperExportService extends ExportService {
  _LooperExportService({
    this.pickerDelay = Duration.zero,
    this.pickerThrows = false,
    this.pickerResult = true,
    this.shareThrows = false,
    this.captureWidth = 2,
    this.captureHeight = 2,
  });

  final Duration pickerDelay;
  final bool pickerThrows;
  final bool pickerResult;
  final bool shareThrows;
  final int captureWidth;
  final int captureHeight;
  int saveCalls = 0;
  int pickerCalls = 0;
  Uint8List? savedBytes;
  String? sharedText;

  @override
  Future<bool> chooseLinuxExportDirectory() async {
    pickerCalls++;
    if (pickerDelay > Duration.zero) await Future<void>.delayed(pickerDelay);
    if (pickerThrows) throw StateError('picker unavailable');
    return pickerResult;
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

class _BlockingLooperPublicationExportService extends _LooperExportService {
  final ExportCoordinator _coordinator = ExportCoordinator();
  final Completer<void> shareStarted = Completer<void>();
  final Completer<void> releaseShare = Completer<void>();

  @override
  ExportCoordinator get coordinator => _coordinator;

  @override
  bool cancelActiveExport() => _coordinator.cancelActive();

  @override
  Future<void> shareFile(File file, {String? text}) async {
    await super.shareFile(file, text: text);
    shareStarted.complete();
    await releaseShare.future;
  }
}

class _BlockingWallpaperExportService extends ExportService {
  final ExportCoordinator _coordinator = ExportCoordinator();
  int saveCalls = 0;

  @override
  ExportCoordinator get coordinator => _coordinator;

  @override
  bool cancelActiveExport() => _coordinator.cancelActive();

  @override
  Future<bool> chooseLinuxExportDirectory() async => true;

  @override
  Future<Uint8List> capturePng(
    GlobalKey key, {
    double pixelRatio = 1.0,
  }) async =>
      Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));

  @override
  Uint8List applyWallpaperStyle(
    Uint8List pngBytes, {
    required String style,
  }) =>
      pngBytes;

  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    saveCalls++;
    return File('/tmp/$filename');
  }
}

class _BlockingWallpaperService extends WallpaperService {
  final Completer<void> publicationStarted = Completer<void>();
  final Completer<void> releasePublication = Completer<void>();

  @override
  Future<bool> setWallpaper(
    Uint8List pngBytes, {
    required WallpaperTarget target,
  }) async {
    publicationStarted.complete();
    await releasePublication.future;
    return true;
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

class _CancelledExportService extends _FallbackScreenSizeExportService {
  int fallbackCaptures = 0;

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
    throw const ExportCancelledException();
  }

  @override
  Future<Uint8List> capturePng(
    GlobalKey key, {
    double pixelRatio = 1.0,
  }) async {
    fallbackCaptures++;
    return super.capturePng(key, pixelRatio: pixelRatio);
  }
}

class _BlockingExportService extends ExportService {
  _BlockingExportService() : _coordinator = ExportCoordinator();

  final ExportCoordinator _coordinator;

  @override
  ExportCoordinator get coordinator => _coordinator;

  @override
  bool cancelActiveExport() => _coordinator.cancelActive();

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
  }) {
    return coordinator.run(ExportKind.image, (token) async {
      await token.whenCancelled;
      token.throwIfCancelled();
      throw StateError('unreachable');
    });
  }
}

class _BlockingFallbackExportService extends ExportService {
  _BlockingFallbackExportService(this.coordinatorOverride)
      : super(coordinator: coordinatorOverride);

  final ExportCoordinator coordinatorOverride;
  final Completer<void> fallbackStarted = Completer<void>();
  final Completer<void> releaseFallbackCapture = Completer<void>();
  int resizeCalls = 0;
  int saveCalls = 0;

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
    throw StateError('ordinary primary failure');
  }

  @override
  Future<Uint8List> capturePng(
    GlobalKey key, {
    double pixelRatio = 1.0,
  }) async {
    fallbackStarted.complete();
    await releaseFallbackCapture.future;
    return Uint8List.fromList(<int>[1]);
  }

  @override
  Uint8List resizePngToTargetDimensions(
    Uint8List pngBytes, {
    required int width,
    required int height,
    String? quoteText,
  }) {
    resizeCalls++;
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
    saveCalls++;
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

class _BlockingPublicationExportService extends ExportService {
  _BlockingPublicationExportService(this.coordinatorOverride)
      : super(coordinator: coordinatorOverride);

  final ExportCoordinator coordinatorOverride;
  final Completer<void> publicationStarted = Completer<void>();
  final Completer<void> releasePublication = Completer<void>();

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
    return ExportResult(
      file: null,
      bytes: Uint8List.fromList(<int>[1]),
      filename: 'publication.png',
      format: ExportFormat.png,
      width: 1,
      height: 1,
      fileSize: 1,
    );
  }

  @override
  Future<void> saveExportResult(ExportResult result) async {
    await _blockPublication();
  }

  @override
  Future<void> shareExportResult(ExportResult result, {String? text}) async {
    await _blockPublication();
  }

  Future<void> _blockPublication() async {
    if (!publicationStarted.isCompleted) publicationStarted.complete();
    await releasePublication.future;
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
    late ViewerSessionStore viewerSessionStore;

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
      viewerSessionStore = await ViewerSessionStore.create();
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
      WallpaperService? wallpaperService,
      bool provideViewerSessionStore = false,
      bool restoreViewerSession = true,
    }) {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          ChangeNotifierProvider.value(value: rendererSettings),
          ChangeNotifierProvider.value(value: historyProvider),
          if (provideViewerSessionStore)
            Provider.value(value: viewerSessionStore),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FractalViewerScreen(
            catalogFamily: catalogFamily,
            exportService: exportService,
            wallpaperService: wallpaperService,
            restoreViewerSession: restoreViewerSession,
          ),
        ),
      );
    }

    testWidgets('lifecycle pause durably saves the exact viewer state',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(provideViewerSessionStore: true),
      );
      await tester.pumpAndSettle();

      controller.selectModule(registry.byId('julia'), animate: false);
      controller.updateParam('iterations', 321);
      controller.updatePan(Vector2(-0.5, 0.25));
      controller.updateZoom(8.0);
      controller.setGlowEnabled(true);
      final expectedIterations = controller.params['iterations'];
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      final restored = viewerSessionStore.load();
      expect(restored, isNotNull);
      expect(restored!.viewerActive, isTrue);
      expect(restored.moduleId, 'julia');
      expect(restored.params['iterations'], expectedIterations);
      expect(restored.params['colorScheme'], controller.params['colorScheme']);
      expect(restored.view.pan.x, -0.5);
      expect(restored.view.pan.y, 0.25);
      expect(restored.view.zoom, 8.0);
      expect(restored.glowEnabled, isTrue);
      historyProvider.cancelPendingRecord();
    });

    testWidgets('restores a durable session before the viewer is rendered',
        (tester) async {
      await viewerSessionStore.save(
        ViewerSessionSnapshot(
          moduleId: 'julia',
          params: const <String, Object>{
            'iterations': 444,
            'colorScheme': 5,
          },
          view: FractalViewState(
            pan: Vector2(0.125, -0.75),
            zoom: 12,
            rotation: Vector3.zero(),
          ),
          transparentBackground: false,
          rotationLocked: true,
          glowEnabled: true,
          glowSigma: 1.5,
          glowIntensity: 0.7,
          fluidModeEnabled: false,
          fluidStrength: 1,
          kaleidoscopeEnabled: false,
          kaleidoscopeSectors: 8,
          kaleidoscopeMirror: true,
          kaleidoscopeRotation: 0,
          kaleidoscopeMirrorMode: 0,
          controlsVisible: true,
          fullscreenUnobtrusive: false,
          viewerActive: true,
        ),
      );

      String? moduleAtFirstPostFrame;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        moduleAtFirstPostFrame = controller.module.id;
      });

      await tester.pumpWidget(
        buildTestWidget(provideViewerSessionStore: true),
      );

      expect(moduleAtFirstPostFrame, 'julia');
      expect(controller.module.id, 'julia');
      expect(controller.params['iterations'], 444);
      expect(controller.view.zoom, 12);
      expect(controller.view.pan.y, -0.75);
      expect(controller.rotationLocked, isTrue);
      expect(controller.glowEnabled, isTrue);
      expect(find.text('Julia'), findsOneWidget);
      expect(find.text('Controls'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets(
        'unknown restored module is rejected without mutating the viewer',
        (tester) async {
      final initialZoom = controller.view.zoom;
      await viewerSessionStore.save(
        ViewerSessionSnapshot(
          moduleId: 'removed_fractal_module',
          params: const <String, Object>{'iterations': 999},
          view: FractalViewState(
            pan: Vector2(4, 5),
            zoom: 77,
            rotation: Vector3.zero(),
          ),
          transparentBackground: false,
          rotationLocked: false,
          glowEnabled: false,
          glowSigma: 1,
          glowIntensity: 1,
          fluidModeEnabled: false,
          fluidStrength: 1,
          kaleidoscopeEnabled: false,
          kaleidoscopeSectors: 6,
          kaleidoscopeMirror: true,
          kaleidoscopeRotation: 0,
          kaleidoscopeMirrorMode: 0,
          controlsVisible: true,
          fullscreenUnobtrusive: false,
          viewerActive: true,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(provideViewerSessionStore: true),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(controller.module.id, 'mandelbrot');
      expect(controller.view.zoom, initialZoom);
    });

    testWidgets('launch deep link suppresses a stale viewer snapshot',
        (tester) async {
      await viewerSessionStore.save(
        ViewerSessionSnapshot(
          moduleId: 'julia',
          params: const <String, Object>{'iterations': 444},
          view: FractalViewState(
            pan: Vector2(0.125, -0.75),
            zoom: 12,
            rotation: Vector3.zero(),
          ),
          transparentBackground: false,
          rotationLocked: false,
          glowEnabled: false,
          glowSigma: 1,
          glowIntensity: 1,
          fluidModeEnabled: false,
          fluidStrength: 1,
          kaleidoscopeEnabled: false,
          kaleidoscopeSectors: 8,
          kaleidoscopeMirror: true,
          kaleidoscopeRotation: 0,
          kaleidoscopeMirrorMode: 0,
          controlsVisible: false,
          fullscreenUnobtrusive: false,
          viewerActive: true,
        ),
      );
      controller.loadState(
        module: registry.byId('domain_coloring'),
        params: const <String, Object>{'iterations': 77},
        view: FractalViewState(
          pan: Vector2(-0.25, 0.5),
          zoom: 3,
          rotation: Vector3.zero(),
        ),
        animateModule: false,
      );

      await tester.pumpWidget(buildTestWidget(
        provideViewerSessionStore: true,
        restoreViewerSession: false,
      ));
      await tester.pumpAndSettle();

      expect(controller.module.id, 'domain_coloring');
      expect(controller.params['iterations'], 77);
      expect(controller.view.zoom, 3);
    });

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

    testWidgets(
        'responsive action hierarchy keeps primary actions visible and secondary actions discoverable',
        (tester) async {
      for (final configuration in const [
        (size: Size(320, 568), textScale: 1.0),
        (size: Size(568, 320), textScale: 1.0),
        (size: Size(768, 1024), textScale: 1.0),
        (size: Size(320, 568), textScale: 2.0),
      ]) {
        await tester.binding.setSurfaceSize(configuration.size);
        tester.platformDispatcher.textScaleFactorTestValue =
            configuration.textScale;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        for (final key in const [
          'viewerRandomParamsButton',
          'viewerColorCycleButton',
          'viewerExportButton',
          'viewerFullscreenButton',
          'viewerRandomFractalFab',
          'viewerLooperFab',
          'viewerFractalMusicFab',
          'viewerKaleidoscopeFab',
          'viewerTextOverlayFab',
          'viewerFourierFab',
          'viewerShareImageButton',
        ]) {
          final finder = find.byKey(ValueKey(key));
          expect(finder, findsOneWidget,
              reason: '$key missing at $configuration');
          final rect = tester.getRect(finder);
          expect(rect.left, greaterThanOrEqualTo(0),
              reason: '$key is left of the viewport at $configuration');
          expect(rect.top, greaterThanOrEqualTo(0),
              reason: '$key is above the viewport at $configuration');
          expect(rect.right, lessThanOrEqualTo(configuration.size.width),
              reason: '$key is right of the viewport at $configuration');
          expect(rect.bottom, lessThanOrEqualTo(configuration.size.height),
              reason: '$key is below the viewport at $configuration');
        }
        expect(tester.takeException(), isNull);
      }
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('auto-explore is reachable from the viewer chrome',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final autoExplore = find.byKey(const ValueKey('viewerAutoExploreButton'));
      expect(autoExplore, findsOneWidget);
      expect(find.byTooltip('Start auto-explore'), findsOneWidget);
      expect(
        tester.getRect(autoExplore).overlaps(
              tester.getRect(find.text('Mandelbrot')),
            ),
        isFalse,
      );
    });

    testWidgets('primary viewer actions expose explicit semantic and tab order',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      const orderedKeys = [
        'viewerAutoExploreButton',
        'viewerRandomParamsButton',
        'viewerColorCycleButton',
        'viewerRandomFractalFab',
        'viewerLooperFab',
        'viewerFractalMusicFab',
        'viewerKaleidoscopeFab',
        'viewerTextOverlayFab',
        'viewerFourierFab',
        'viewerShareImageButton',
        'viewerExportButton',
        'viewerFullscreenButton',
        'viewerReportFractalFab',
      ];
      for (var index = 0; index < orderedKeys.length; index++) {
        final finder = find.byKey(ValueKey(orderedKeys[index]));
        final semanticWidget = tester.widget<Semantics>(
          find.descendant(
            of: finder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.sortKey != null,
            ),
          ),
        );
        final sortKey = semanticWidget.properties.sortKey;
        expect(sortKey, isA<OrdinalSortKey>());
        expect((sortKey! as OrdinalSortKey).order, index);
        expect(tester.getSize(finder).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focusable = find.descendant(
          of: finder,
          matching: find.byType(FocusableActionDetector),
        );
        expect(Focus.of(tester.element(focusable)).hasFocus, isTrue,
            reason: '${orderedKeys[index]} was not tab stop ${index + 1}');
      }
      semantics.dispose();
    });

    testWidgets('promoted actions expose localized labels and hints',
        (tester) async {
      for (final locale in const [Locale('en'), Locale('es')]) {
        await tester.pumpWidget(buildTestWidget(locale: locale));
        await tester.pumpAndSettle();

        final expectedLabel = locale.languageCode == 'es'
            ? 'Vista de Fourier desactivada'
            : 'Fourier view off';
        final expectedHint = locale.languageCode == 'es'
            ? 'Muestra el fractal actual en los dominios espacial y de frecuencia. '
                'Mantén pulsado o usa Mayús+Intro para abrir la acción secundaria.'
            : 'View the current fractal in spatial and frequency domains. '
                'Long press or Shift+Enter opens the secondary action.';
        final semantics = tester.widget<Semantics>(
          find.descendant(
            of: find.byKey(const ValueKey('viewerFourierFab')),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label == expectedLabel,
            ),
          ),
        );
        expect(semantics.properties.hint, expectedHint);
      }
    });

    testWidgets('fractal music action is directly discoverable',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final music = find.byKey(const ValueKey('viewerFractalMusicFab'));
      expect(music, findsOneWidget);
      await tester.ensureVisible(music);
      await tester.pumpAndSettle();
      final rect = tester.getRect(music);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(600));
      expect(
          find.descendant(of: music, matching: find.byIcon(Icons.music_note)),
          findsOneWidget);
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

      final randomButton = find.byKey(const ValueKey('viewerRandomFractalFab'));
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

    testWidgets('share image FAB rejects re-entry during export setup',
        (tester) async {
      final exportService = _LooperExportService(
        pickerDelay: const Duration(milliseconds: 250),
        pickerResult: false,
      );
      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();

      final share = find.byKey(const ValueKey('viewerShareImageButton'));
      await tester.tap(share);
      await tester.pump();
      final shareGesture = tester.widget<GestureDetector>(find.descendant(
        of: share,
        matching: find.byType(GestureDetector),
      ));
      expect(shareGesture.onTap, isNull);
      await tester.tap(share);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(exportService.pickerCalls, 1);
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

    testWidgets('cancelled image export never starts the PNG fallback',
        (tester) async {
      final exportService = _CancelledExportService();

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pumpAndSettle();

      expect(exportService.fallbackCaptures, 0);
    });

    testWidgets(
        'ordinary failure fallback retains the image lease and honours Back cancellation',
        (tester) async {
      final coordinator = ExportCoordinator();
      final exportService = _BlockingFallbackExportService(coordinator);

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pump();
      await exportService.fallbackStarted.future;

      expect(coordinator.activeKind, ExportKind.image);
      await expectLater(
        coordinator.run(ExportKind.video, (_) async => 1),
        throwsA(isA<ExportBusyException>()),
      );

      await tester.binding.handlePopRoute();
      exportService.releaseFallbackCapture.complete();
      await tester.pumpAndSettle();

      expect(coordinator.isBusy, isFalse);
      expect(exportService.resizeCalls, 0);
      expect(exportService.saveCalls, 0);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
    });

    testWidgets('publication retains the image lease and honours cancellation',
        (tester) async {
      final coordinator = ExportCoordinator();
      final exportService = _BlockingPublicationExportService(coordinator);

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pump();
      await exportService.publicationStarted.future;

      expect(coordinator.activeKind, ExportKind.image);
      await expectLater(
        coordinator.run(ExportKind.video, (_) async => 1),
        throwsA(isA<ExportBusyException>()),
      );

      await tester.binding.handlePopRoute();
      exportService.releasePublication.complete();
      await tester.pumpAndSettle();

      expect(coordinator.isBusy, isFalse);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
    });

    testWidgets(
        'wallpaper persistence and publication retain the image lease and cancel',
        (tester) async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);
      final exportService = _BlockingWallpaperExportService();
      final wallpaperService = _BlockingWallpaperService();

      await tester.pumpWidget(buildTestWidget(
        exportService: exportService,
        wallpaperService: wallpaperService,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportWallpaperButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pump();
      await wallpaperService.publicationStarted.future;

      expect(exportService.saveCalls, 1);
      expect(exportService.coordinator.activeKind, ExportKind.image);
      await expectLater(
        exportService.coordinator.run(ExportKind.video, (_) async => 1),
        throwsA(isA<ExportBusyException>()),
      );

      await tester.binding.handlePopRoute();
      wallpaperService.releasePublication.complete();
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = previousPlatform;

      expect(exportService.coordinator.isBusy, isFalse);
      expect(find.text('Wallpaper ready'), findsNothing);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
    });

    testWidgets('system Back cancels an active image export before route pop',
        (tester) async {
      final exportService = _BlockingExportService();

      await tester.pumpWidget(buildTestWidget(exportService: exportService));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await tester.pump();

      expect(exportService.coordinator.isBusy, isTrue);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(exportService.coordinator.isBusy, isFalse);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
    });

    testWidgets('performance family route hides core viewer chrome',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(catalogFamily: CatalogFamily.performance),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('viewerRandomFractalFab')), findsNothing);
      expect(
          find.byKey(const ValueKey('viewerRandomParamsButton')), findsNothing);
      expect(find.byKey(const ValueKey('viewerFractalMusicFab')), findsNothing);
      expect(
          find.byTooltip('Randomize. Long press for Controls'), findsNothing);
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

    testWidgets('controls FAB long press opens controls sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // A single press randomizes the parameters instead of opening the panel;
      // long press is what reveals the Controls HUD.
      await tester.tap(
        find.byKey(const ValueKey('viewerRandomParamsButton')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Controls'), findsNothing);

      await tester.longPress(
        find.byKey(const ValueKey('viewerRandomParamsButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);

      // The randomize tap queues a history-record debounce timer; drain it so
      // the test harness does not see a pending timer at teardown.
      await tester.pump(const Duration(milliseconds: 400));
      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('controls HUD supports modules without core params',
        (tester) async {
      controller.selectModule(registry.byId('test_minimal'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.longPress(
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

      await tester.tap(find.byKey(const ValueKey('viewerLooperFab')));
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
      if (settleAfterExport) {
        await tester.pumpAndSettle();
        for (var attempt = 0;
            attempt < 100 && exportService.coordinator.isBusy;
            attempt++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }
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

    testWidgets('looper publication retains its lease and honours cancellation',
        (tester) async {
      final exportService = _BlockingLooperPublicationExportService();
      await exportLooper(
        tester,
        exportService,
        settleAfterExport: false,
      );
      for (var attempt = 0;
          attempt < 100 && !exportService.shareStarted.isCompleted;
          attempt++) {
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      await exportService.shareStarted.future;

      expect(exportService.coordinator.activeKind, ExportKind.looper);
      await expectLater(
        exportService.coordinator.run(ExportKind.video, (_) async => 1),
        throwsA(isA<ExportBusyException>()),
      );

      await tester.binding.handlePopRoute();
      exportService.releaseShare.complete();
      await tester.pumpAndSettle();

      expect(exportService.coordinator.isBusy, isFalse);
      expect(find.text('Looper GIF exported'), findsNothing);
      expect(find.byKey(const Key('fractalViewerRoot')), findsOneWidget);
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
