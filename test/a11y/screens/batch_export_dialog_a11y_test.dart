import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/batch_export_service.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/export/batch_export_dialog.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_guard.dart';
import '../semantics/interactive_name_audit.dart';
import '../shared/a11y_test_helpers.dart';

/// Answers the directory prompt without opening a picker.
///
/// The real one blocks on a platform picker whose future never resolves under
/// test, which is why every state of this dialog past its first frame had gone
/// unmeasured.
class _FakeExportService extends ExportService {
  const _FakeExportService();

  @override
  Future<bool> chooseLinuxExportDirectory() async => true;
}

/// A 1x1 transparent PNG, so the tiles' Image.file has something to decode.
const _onePixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _FakeBatchExportService implements BatchExportService {
  _FakeBatchExportService({
    required this.directory,
    this.itemCount = 0,
    this.throwError = false,
    this.contactSheet,
  });

  final Directory directory;
  final int itemCount;
  final bool throwError;
  final File? contactSheet;

  @override
  Future<BatchExportResult> exportPresets({
    required GlobalKey boundaryKey,
    required Future<void> Function(FractalPreset preset) applyPreset,
    required List<FractalPreset> presets,
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required String moduleId,
    required String moduleDisplayName,
    required Map<String, Object> Function() currentParameters,
    required void Function(double overallProgress, String status)? onProgress,
    required void Function(BatchExportItemResult item)? onItemDone,
    required bool Function() isCancelled,
  }) async {
    if (throwError) throw StateError('capture failed on preset 2 of 12');
    final items = <BatchExportItemResult>[];
    for (var i = 0; i < itemCount; i++) {
      final file = File('${directory.path}/item$i.png');
      file.writeAsBytesSync(Uint8List.fromList(_onePixelPng));
      final item = BatchExportItemResult(
        preset: presets[i % presets.length],
        file: file,
        index: i,
      );
      items.add(item);
      onProgress?.call((i + 1) / itemCount, 'Exporting ${i + 1}/$itemCount');
      onItemDone?.call(item);
    }
    return BatchExportResult(
      directory: directory,
      items: items,
      contactSheet: contactSheet,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BlockingCancelledBatchExportService implements BatchExportService {
  final Completer<void> started = Completer<void>();
  final Completer<void> cancelled = Completer<void>();

  @override
  Future<BatchExportResult> exportPresets({
    required GlobalKey boundaryKey,
    required Future<void> Function(FractalPreset preset) applyPreset,
    required List<FractalPreset> presets,
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required String moduleId,
    required String moduleDisplayName,
    required Map<String, Object> Function() currentParameters,
    required void Function(double overallProgress, String status)? onProgress,
    required void Function(BatchExportItemResult item)? onItemDone,
    required bool Function() isCancelled,
  }) async {
    started.complete();
    await cancelled.future;
    throw const ExportCancelledException();
  }

  @override
  void cancelActiveExport() {
    if (!cancelled.isCompleted) cancelled.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BatchExportDialog accessibility', () {
    late Directory dir;
    late ModuleRegistry registry;
    late FractalController fractal;
    late PresetStore store;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      dir = Directory.systemTemp.createTempSync('batch_export_a11y_');
      registry = ModuleRegistry();
      fractal = FractalController(registry);
      store = await PresetStore.create();
    });

    tearDown(() {
      fractal.dispose();
      dir.deleteSync(recursive: true);
    });

    Future<void> pumpDialog(
      WidgetTester tester, {
      double textScale = 1.0,
      Size? size,
      int itemCount = 9,
      bool throwError = false,
      bool withContactSheet = true,
      BatchExportService? batchExportService,
    }) async {
      if (size != null) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
      }
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: fractal),
          Provider<ModuleRegistry>.value(value: registry),
          Provider<PresetStore>.value(value: store),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: BatchExportDialog(
            boundaryKey: GlobalKey(),
            exportService: const _FakeExportService(),
            batchExportService: batchExportService ??
                _FakeBatchExportService(
                  directory: dir,
                  itemCount: itemCount,
                  throwError: throwError,
                  contactSheet:
                      withContactSheet ? File('${dir.path}/contact.png') : null,
                ),
          ),
        ),
      ));
      await pumpAccessibilityTestFrames(tester);
    }

    // With the services built inline the dialog never got past awaiting a
    // directory: status stayed empty and only the title, the close button and
    // the placeholder ever rendered. Anything asserted on that frame passes
    // whatever the rest of the dialog does.
    testWidgets('the injected services carry it past the first frame',
        (tester) async {
      await pumpDialog(tester);

      expect(find.text('Done'), findsOneWidget,
          reason: 'the dialog is still awaiting an export directory');
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDialog(tester);
      final root = semanticsRoot(tester);

      expect(operableControlNames(root), isNotEmpty,
          reason: 'nothing rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // The grid sat in the only Expanded of a column of otherwise fixed chrome.
    // As the text scale grew the status line, error panel and saved-path footer
    // claimed the height and the grid was starved to nothing: every exported
    // image vanished from a dialog whose whole purpose is showing them.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
      ]) {
        testWidgets('the grid keeps its items at ${scale}x on $size',
            (tester) async {
          await pumpDialog(tester, textScale: scale, size: size);

          expect(tester.getSize(find.byType(GridView)).height, greaterThan(0),
              reason: 'the grid collapsed, so the exports are not shown');
          // Height alone is not enough: a grid can measure a few pixels and
          // still show nothing. "Classic" is the first built-in preset, and at
          // 2.0x and above no preset name reached the screen at all.
          expect(find.text('Classic', skipOffstage: false), findsOneWidget,
              reason: 'no exported item is on screen');
          await disposeAccessibilityTestWidget(tester);
        });

        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await expectNoOverflow(
            () => pumpDialog(tester, textScale: scale, size: size),
            reason: '$scale x on $size',
          );
          await disposeAccessibilityTestWidget(tester);
        });

        testWidgets('no overflow reporting a failure at ${scale}x on $size',
            (tester) async {
          await expectNoOverflow(
            () => pumpDialog(tester,
                textScale: scale, size: size, throwError: true),
            reason: 'error state at ${scale}x on $size',
          );
          await disposeAccessibilityTestWidget(tester);
        });
      }
    }

    // The catch left the status line and the placeholder untouched, so a failed
    // run showed "Preparing…" above "Export failed" and "Done" below it.
    testWidgets('a failure is not reported as progress or success',
        (tester) async {
      await pumpDialog(tester, throwError: true);

      expect(find.textContaining('Export failed'), findsOneWidget);
      expect(find.text('Preparing…'), findsNothing);
      expect(find.text('Done'), findsNothing);
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('cancelling before the first item never reports done',
        (tester) async {
      final service = _BlockingCancelledBatchExportService();
      await pumpDialog(tester, batchExportService: service);
      await service.started.future;

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDialog(tester);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // The saved-path footer and the placeholder both used textMuted, which is
    // 3.92:1 against this dialog's background — below the 4.5:1 floor. The
    // guideline above does not catch it, so the colour is asserted directly.
    testWidgets('the saved-path footer is legible', (tester) async {
      await pumpDialog(tester);

      final footer = tester.widget<Text>(
        find.textContaining('Saved to:'),
      );
      expect(footer.style?.color, isNot(AppColors.textMuted));
      expect(footer.maxLines, 2,
          reason: 'an unbounded path grows without limit and starves the grid');
      await disposeAccessibilityTestWidget(tester);
    });
  });
}
