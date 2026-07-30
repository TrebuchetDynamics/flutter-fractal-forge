import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/overflow_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Overflow detection tests.
///
/// Overrides [FlutterError.onError] to catch RenderFlex overflow errors at
/// normal and large text scale (3.0) in both light and dark themes.
void main() {
  late PresetStore presetStore;
  late HistoryStore historyStore;
  late AccessibilityService accessibilityService;
  late RendererSettingsService rendererSettingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final results = await Future.wait([
      PresetStore.create(),
      HistoryStore.create(),
      AccessibilityService.create(),
      RendererSettingsService.create(),
      PaletteService.create(),
    ]);
    presetStore = results[0] as PresetStore;
    historyStore = results[1] as HistoryStore;
    accessibilityService = results[2] as AccessibilityService;
    rendererSettingsService = results[3] as RendererSettingsService;
  });

  /// Wraps [child] in a MaterialApp shell with providers, theme, and
  /// localization matching the real app.
  Widget buildTestShell({
    required Widget child,
    ThemeData? theme,
    double textScaleFactor = 1.0,
  }) {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);

    return MultiProvider(
      providers: [
        Provider<ModuleRegistry>(create: (_) => registry),
        Provider<PresetStore>.value(value: presetStore),
        Provider<HistoryStore>.value(value: historyStore),
        ChangeNotifierProvider<AccessibilityService>.value(
          value: accessibilityService,
        ),
        ChangeNotifierProvider<RendererSettingsService>.value(
          value: rendererSettingsService,
        ),
        ChangeNotifierProvider<FractalController>.value(value: controller),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
        child: MaterialApp(
          theme: theme ?? AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  /// Pumps [widget] inside the test shell and asserts that no RenderFlex
  /// overflow occurs.
  Future<void> assertNoOverflow(
    WidgetTester tester,
    Widget widget, {
    ThemeData? theme,
    double textScaleFactor = 1.0,
    String label = '',
    Size? surfaceSize,
  }) async {
    if (surfaceSize != null) {
      await tester.binding.setSurfaceSize(surfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }
    // Shared guard so a failure names the widget that overflowed, and so a
    // widget that is disposed before the assertion still gets reported.
    await expectNoOverflow(
      () async {
        await tester.pumpWidget(buildTestShell(
          child: widget,
          theme: theme,
          textScaleFactor: textScaleFactor,
        ));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      },
      reason: 'RenderFlex overflow detected $label',
    );
  }

  group('Overflow Detection — Catalog Screen', () {
    testWidgets('no overflow at normal text scale (dark theme)',
        (tester) async {
      await assertNoOverflow(
        tester,
        const FractalCatalogScreen(),
        theme: AppTheme.dark,
        label: 'Catalog / dark / 1.0x',
      );
    });

    // Known issue: catalog search bar and section headers overflow at 3.0x text
    // scale. Tracked for P2 fix (controls ergonomics / large-text support).
    testWidgets(
      'no overflow at large text scale 3.0 (dark theme)',
      (tester) async {
        await assertNoOverflow(
          tester,
          const FractalCatalogScreen(),
          theme: AppTheme.dark,
          textScaleFactor: 3.0,
          label: 'Catalog / dark / 3.0x',
        );
      },
    );

    testWidgets('no overflow at normal text scale (high contrast)',
        (tester) async {
      await assertNoOverflow(
        tester,
        const FractalCatalogScreen(),
        theme: AppTheme.highContrast,
        label: 'Catalog / highContrast / 1.0x',
      );
    });

    // Known issue: same overflow as dark theme at 3.0x.
    testWidgets(
      'no overflow at large text scale 3.0 (high contrast)',
      (tester) async {
        await assertNoOverflow(
          tester,
          const FractalCatalogScreen(),
          theme: AppTheme.highContrast,
          textScaleFactor: 3.0,
          label: 'Catalog / highContrast / 3.0x',
        );
      },
    );
  });

  group('Overflow Detection — Export Options Sheet', () {
    Widget buildExportSheet() {
      return const ExportOptionsSheet(
        initialOptions: ExportOptions(),
        fractalType: 'mandelbrot',
      );
    }

    testWidgets('no overflow at normal text scale (dark theme)',
        (tester) async {
      await assertNoOverflow(
        tester,
        buildExportSheet(),
        theme: AppTheme.dark,
        label: 'ExportSheet / dark / 1.0x',
      );
    });

    testWidgets('no overflow at large text scale 3.0 (dark theme)',
        (tester) async {
      await assertNoOverflow(
        tester,
        buildExportSheet(),
        theme: AppTheme.dark,
        textScaleFactor: 3.0,
        label: 'ExportSheet / dark / 3.0x',
      );
    });

    testWidgets('no overflow at normal text scale (high contrast)',
        (tester) async {
      await assertNoOverflow(
        tester,
        buildExportSheet(),
        theme: AppTheme.highContrast,
        label: 'ExportSheet / highContrast / 1.0x',
      );
    });

    testWidgets('no overflow at large text scale 3.0 (high contrast)',
        (tester) async {
      await assertNoOverflow(
        tester,
        buildExportSheet(),
        theme: AppTheme.highContrast,
        textScaleFactor: 3.0,
        label: 'ExportSheet / highContrast / 3.0x',
      );
    });

    // The cases above render at the default 800x600 test surface, where the
    // sheet has enough width to absorb any text growth. Phone widths are where
    // it actually breaks, so scale is swept there too.
    for (final surface in const [Size(360, 640), Size(320, 568)]) {
      for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
        testWidgets('no overflow at ${scale}x on $surface', (tester) async {
          await assertNoOverflow(
            tester,
            buildExportSheet(),
            theme: AppTheme.dark,
            textScaleFactor: scale,
            surfaceSize: surface,
            label: 'ExportSheet / dark / ${scale}x / $surface',
          );
        });
      }
    }
  });
}
