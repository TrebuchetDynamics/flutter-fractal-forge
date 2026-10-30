import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/permission_test_harness.dart';

Future<FractalController> _pumpViewer(
  WidgetTester tester,
  Future<Uint8List> Function(double) capture,
) async {
  SharedPreferences.setMockInitialValues({});
  installDenyAllPermissionsHandler();
  await tester.binding.setSurfaceSize(const Size(390, 844));
  final registry = ModuleRegistry();
  final controller = FractalController(registry);
  final presets = await PresetStore.create();
  final renderer = await RendererSettingsService.create();
  final history = HistoryProvider(store: await HistoryStore.create());
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    history.dispose();
    controller.dispose();
    renderer.dispose();
    await tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(MultiProvider(
    providers: [
      Provider.value(value: registry),
      ChangeNotifierProvider.value(value: controller),
      Provider.value(value: presets),
      ChangeNotifierProvider.value(value: renderer),
      ChangeNotifierProvider.value(value: history),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FractalViewerScreen(
        restoreViewerSession: false,
        exportService: ExportService(capture: capture),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _openShare(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
  await tester.pumpAndSettle();
  final linkAction = find.byKey(const ValueKey('viewerShareLinkAction'));
  await tester.ensureVisible(linkAction);
  await tester.tap(linkAction);
  await tester.pumpAndSettle();
  expect(find.byType(ShareSheet), findsOneWidget);
}

Uint8List _previewPng() {
  final image = img.Image(width: 12, height: 16);
  img.fill(image, color: img.ColorRgb8(24, 180, 210));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  testWidgets('viewer captures artwork preview without changing shared state',
      (tester) async {
    var captures = 0;
    final preview = Completer<Uint8List>();
    final controller = await _pumpViewer(tester, (ratio) {
      captures++;
      expect(ratio, greaterThan(0));
      expect(ratio, lessThanOrEqualTo(1));
      return preview.future;
    });
    final params = Map<String, dynamic>.from(controller.params);
    final view = controller.view;
    await _openShare(tester);
    expect(captures, 1);
    final initialLink = tester.widget<ShareSheet>(find.byType(ShareSheet)).uri;
    expect(initialLink.queryParameters['t'], controller.module.id);
    final bytes = _previewPng();
    preview.complete(bytes);
    await tester.pumpAndSettle();
    final image = find.descendant(
      of: find.byType(ShareSheet),
      matching: find.byType(Image),
    );
    expect(image, findsOneWidget);
    expect((tester.widget<Image>(image).image as MemoryImage).bytes, bytes);
    expect(controller.params, params);
    expect(controller.view.pan, view.pan);
    expect(controller.view.zoom, view.zoom);
    expect(controller.view.rotation, view.rotation);
    expect(controller.view.trajectory, view.trajectory);
    expect(tester.widget<ShareSheet>(find.byType(ShareSheet)).uri, initialLink);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'preview completion retains the link captured when sharing opened',
      (tester) async {
    final preview = Completer<Uint8List>();
    final controller = await _pumpViewer(tester, (_) => preview.future);
    await _openShare(tester);
    final link = tester.widget<ShareSheet>(find.byType(ShareSheet)).uri;
    final iterations = (controller.params['iterations'] as num).toInt() - 1;
    controller.updateParam('iterations', iterations);
    // Complete the real history debounce triggered by this intentional edit.
    await tester.pump(const Duration(milliseconds: 500));
    preview.complete(_previewPng());
    await tester.pumpAndSettle();
    expect(tester.widget<ShareSheet>(find.byType(ShareSheet)).uri, link);
    expect(controller.params['iterations'], iterations);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'preview deadline keeps link sharing usable and ignores late bytes',
      (tester) async {
    final preview = Completer<Uint8List>();
    await _pumpViewer(tester, (_) => preview.future);
    await _openShare(tester);
    final link = tester.widget<ShareSheet>(find.byType(ShareSheet)).uri;
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(ShareSheet), findsOneWidget);
    preview.complete(_previewPng());
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byType(ShareSheet), matching: find.byType(Image)),
        findsNothing);
    expect(tester.widget<ShareSheet>(find.byType(ShareSheet)).uri, link);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview failure leaves the full share link usable',
      (tester) async {
    var captures = 0;
    await _pumpViewer(tester, (_) async {
      captures++;
      throw StateError('render boundary not available');
    });
    await _openShare(tester);
    expect(captures, 1);
    expect(tester.widget<ShareSheet>(find.byType(ShareSheet)).uri.query,
        isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late preview completion after dismissal does not reopen sheet',
      (tester) async {
    var captures = 0;
    final preview = Completer<Uint8List>();
    await _pumpViewer(tester, (_) {
      captures++;
      return preview.future;
    });
    await _openShare(tester);
    expect(captures, 1);
    final close = find.descendant(
      of: find.byType(ShareSheet),
      matching: find.byTooltip('Close'),
    );
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.byType(ShareSheet), findsNothing);
    preview.complete(_previewPng());
    await tester.pumpAndSettle();
    expect(find.byType(ShareSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
