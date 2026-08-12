import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/wallpaper_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_guard.dart';
import '../shared/a11y_test_helpers.dart';

class _FakeExportService extends ExportService {
  _FakeExportService({this.pickerOk = true, this.saveThrows = false});

  final bool pickerOk;
  final bool saveThrows;
  int saveCalls = 0;

  @override
  Future<bool> chooseLinuxExportDirectory() async => pickerOk;

  @override
  Future<Uint8List> capturePng(GlobalKey key,
          {double pixelRatio = 1.0}) async =>
      Uint8List.fromList(const [1, 2, 3, 4]);

  @override
  Uint8List applyWallpaperStyle(Uint8List bytes, {required String style}) =>
      bytes;

  @override
  String generateFilename({
    String prefix = 'fractal',
    required ExportFormat format,
    String? fractalType,
  }) =>
      'wp.png';

  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    saveCalls++;
    if (saveThrows) throw const FileSystemException('disk full');
    return File('/fake/$filename');
  }
}

class _FakeWallpaperService implements WallpaperService {
  _FakeWallpaperService({this.ok = true, this.throws = false});

  final bool ok;
  final bool throws;
  int calls = 0;

  @override
  Future<bool> setWallpaper(Uint8List bytes,
      {required WallpaperTarget target}) async {
    calls++;
    if (throws) throw StateError('channel unavailable');
    return ok;
  }

  @override
  Future<bool> saveToPhotos(Uint8List bytes) async => ok;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  group('Apply wallpaper', () {
    late _FakeExportService exportService;
    late _FakeWallpaperService wallpaperService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      exportService = _FakeExportService();
      wallpaperService = _FakeWallpaperService();
    });

    Future<void> applyWallpaper(
      WidgetTester tester, {
      double textScale = 1.0,
      Size size = const Size(360, 640),
      Locale locale = const Locale('en'),
    }) async {
      // The wallpaper tile only exists where the platform supports it.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Without this the flow suspends forever partway through, at the haptic
      // that fires just before its feedback: HapticFeedback never completes
      // under flutter_test unless SystemChannels.platform is mocked. Nothing
      // past that point in this path — every snackbar it shows — is reachable
      // otherwise, which is part of why none of it had been measured.
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (call) async => null);
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      final registry = ModuleRegistry();
      final fractal = FractalController(registry);
      addTearDown(fractal.dispose);
      final accessibility = await AccessibilityService.create();
      final rendererSettings = await RendererSettingsService.create();
      addTearDown(rendererSettings.dispose);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: fractal),
          Provider<ModuleRegistry>.value(value: registry),
          ChangeNotifierProvider<AccessibilityService>.value(
              value: accessibility),
          ChangeNotifierProvider<RendererSettingsService>.value(
              value: rendererSettings),
          Provider<ExplorationStatsService?>.value(value: null),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: FractalViewerScreen(
            exportService: exportService,
            wallpaperService: wallpaperService,
          ),
        ),
      ));
      await pumpAccessibilityTestFrames(tester);

      // The user's route: export FAB long-press, wallpaper tile, then Apply.
      // The action sheet scrolls, so the tile needs bringing into view before
      // it can be tapped at anything above the smallest text scale.
      await tester.longPress(find.byKey(const ValueKey('viewerExportButton')));
      await tester.pumpAndSettle();
      final es = locale.languageCode == 'es';
      final tile = find.text(es ? 'Fondo de pantalla' : 'Wallpaper').last;
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      final apply = find.text(es ? 'Aplicar' : 'Apply');
      await tester.ensureVisible(apply);
      await tester.pumpAndSettle();
      await tester.tap(apply);
      await tester.pumpAndSettle();

      // Cleared inside the body: the framework's debug-variable invariant is
      // checked before addTearDown callbacks run.
      debugDefaultTargetPlatformOverride = null;
    }

    testWidgets('a successful apply says so', (tester) async {
      await applyWallpaper(tester);

      expect(wallpaperService.calls, 1,
          reason: 'the flow never reached the platform');
      expect(find.text('Wallpaper ready'), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    // The copy is something the user ticked a box to ask for. A failure used to
    // go to the log only, and the snackbar still read "Wallpaper ready" — the
    // exact shape ViewerExportFeedback exists to prevent for export.
    testWidgets('a failed copy is reported, not just logged', (tester) async {
      exportService = _FakeExportService(saveThrows: true);
      await applyWallpaper(tester);

      expect(exportService.saveCalls, 1);
      expect(wallpaperService.calls, 1,
          reason: 'a failed copy must not stop the wallpaper being set');
      expect(find.text('Wallpaper ready'), findsNothing);
      expect(find.textContaining('copy couldn’t be saved'), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('a refused platform call is reported', (tester) async {
      wallpaperService = _FakeWallpaperService(ok: false);
      await applyWallpaper(tester);

      expect(find.text('Couldn’t apply wallpaper'), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('a thrown platform call is reported', (tester) async {
      wallpaperService = _FakeWallpaperService(throws: true);
      await applyWallpaper(tester);

      expect(find.textContaining('Couldn’t apply wallpaper:'), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    // Cancelling the directory picker cancels the copy, which is a reasonable
    // reading of the gesture — but the wallpaper is still applied, so this
    // pins that the flow continues rather than silently aborting.
    testWidgets('cancelling the picker still applies the wallpaper',
        (tester) async {
      exportService = _FakeExportService(pickerOk: false);
      await applyWallpaper(tester);

      expect(exportService.saveCalls, 0);
      expect(wallpaperService.calls, 1);
      expect(find.text('Wallpaper ready'), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    // The theme's snackbar content colour is textPrimary, which is 2.55:1 on
    // AppColors.success and 3.2:1 on AppColors.error — both under 4.5:1.
    // textContrastGuideline does not reach a floating snackbar, so the
    // foreground is asserted directly.
    testWidgets('its feedback is legible on both backgrounds', (tester) async {
      await applyWallpaper(tester);
      final success = tester.widget<Text>(find.text('Wallpaper ready'));
      expect(success.style?.color, AppColors.background);

      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('its failure feedback is legible', (tester) async {
      wallpaperService = _FakeWallpaperService(ok: false);
      await applyWallpaper(tester);
      final failure =
          tester.widget<Text>(find.text('Couldn’t apply wallpaper'));
      expect(failure.style?.color, AppColors.background);
      await disposeAccessibilityTestWidget(tester);
    });

    for (final scale in const [1.0, 2.0, 3.0]) {
      testWidgets('no overflow reporting success at ${scale}x', (tester) async {
        await expectNoOverflow(
          () => applyWallpaper(tester, textScale: scale),
          reason: 'success feedback at ${scale}x',
        );
        await disposeAccessibilityTestWidget(tester);
      });

      testWidgets('no overflow reporting a failure at ${scale}x',
          (tester) async {
        wallpaperService = _FakeWallpaperService(throws: true);
        await expectNoOverflow(
          () => applyWallpaper(tester, textScale: scale),
          reason: 'failure feedback at ${scale}x',
        );
        await disposeAccessibilityTestWidget(tester);
      });
    }

    testWidgets('the copy-failed message localizes', (tester) async {
      exportService = _FakeExportService(saveThrows: true);
      await applyWallpaper(tester, locale: const Locale('es'));

      expect(
          find.textContaining('no se pudo guardar la copia'), findsOneWidget);
      expect(find.textContaining('copy couldn’t be saved'), findsNothing);
      await disposeAccessibilityTestWidget(tester);
    });
  });
}
