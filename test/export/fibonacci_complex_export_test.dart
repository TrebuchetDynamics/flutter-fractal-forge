import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/features/viewer/export/fibonacci_complex_export.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../helpers/fibonacci_complex_render.dart';

FractalRenderSnapshot snapshot(
        FractalModule module, Map<String, Object> params, bool transparent) =>
    FractalRenderSnapshot(
        module: module,
        state: FractalRenderState(
            params: params,
            view: FractalViewState(
                pan: Vector2(.2, -.1), zoom: 1.4, rotation: Vector3.zero()),
            transparentBackground: transparent),
        time: 0,
        glowEnabled: false,
        glowSigma: 1,
        glowIntensity: .35,
        kaleidoscopeEnabled: false,
        kaleidoscopeSectors: 8,
        kaleidoscopeMirror: true,
        kaleidoscopeRotation: 0,
        kaleidoscopeMirrorMode: 0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'frozen edited snapshot exports decoded RGB on GPU and CPU despite later navigation',
      () async {
    SharedPreferences.setMockInitialValues({});
    final root = await Directory(
            Platform.environment['TMPDIR'] ?? Directory.systemTemp.path)
        .createTemp('fib-export-');
    addTearDown(() => root.delete(recursive: true));
    final service = ExportService(coordinator: ExportCoordinator());
    await service.setPreferredExportDirectory(root);
    final registry = ModuleRegistry();
    final module = registry.byId('fibonacci_complex_julia');
    final controller = FractalController(registry)
      ..selectModule(module, animate: false);
    addTearDown(controller.dispose);
    final params = <String, Object>{
      ...module.defaultPreset.params,
      'iterations': 11,
      'juliaCReal': -.3,
      'juliaCImag': .3
    };
    final state = snapshot(module, params, false);
    final captures = [
      for (final cpu in [false, true])
        FibonacciComplexExportCapture(
            snapshot: state, requiresCpu: cpu, width: 32, height: 24)
    ];
    params['iterations'] = 1;
    params['juliaCReal'] = 2.0;
    controller.selectModule(registry.byId('julia'), animate: false);
    controller
        .updateView(controller.view.copyWith(pan: Vector2(-2, 2), zoom: 9));
    expect(captures.first.snapshot.state.params['iterations'], 11);
    expect(captures.first.snapshot.state.params['juliaCReal'], -.3);
    final expected = await drawFibonacciPng(
        module, captures.first.snapshot.state,
        width: 32, height: 24);
    for (final capture in captures) {
      final result = await service
          .withCapture(capture.capturePng)
          .exportWithOptions(GlobalKey(),
              options: const ExportOptions(
                  resolution: ExportResolution.custom,
                  customWidth: 32,
                  customHeight: 24,
                  addWatermark: false),
              screenWidth: 32,
              screenHeight: 24,
              fractalType: module.id,
              parameters: capture.snapshot.state.params);
      final decoded = img.decodePng(await result.file!.readAsBytes())!;
      expect([decoded.width, decoded.height], [32, 24]);
      var differences = 0;
      for (var y = 0; y < 24; y++) {
        for (var x = 0; x < 32; x++) {
          final a = decoded.getPixel(x, y), b = expected.getPixel(x, y);
          if ((a.r - b.r).abs() > 1 ||
              (a.g - b.g).abs() > 1 ||
              (a.b - b.b).abs() > 1) differences++;
          expect(a.a, 255);
        }
      }
      expect(differences, lessThanOrEqualTo(7),
          reason: 'At most 1% float-boundary disagreements.');
      print(
          'export cpu=${capture.requiresCpu}: 32x24, boundary disagreements=$differences');
      final evidence = Platform.environment['FIBONACCI_EVIDENCE_DIR'];
      if (evidence != null) {
        await Directory(evidence).create(recursive: true);
        await result.file!.copy(
            '$evidence/export-${capture.requiresCpu ? 'cpu' : 'gpu'}.png');
      }
    }
    final before = root.listSync().map((f) => f.path).toSet();
    final started = Completer<void>(), release = Completer<void>();
    final pending = service.withCapture((ratio) async {
      started.complete();
      await release.future;
      return captures.first.capturePng(ratio);
    }).exportWithOptions(GlobalKey(),
        options: const ExportOptions(
            resolution: ExportResolution.custom,
            customWidth: 32,
            customHeight: 24),
        screenWidth: 32,
        screenHeight: 24,
        fractalType: module.id,
        parameters: state.state.params);
    final cancelled =
        expectLater(pending, throwsA(isA<ExportCancelledException>()));
    await started.future;
    service.cancelActiveExport();
    release.complete();
    await cancelled;
    expect(root.listSync().map((f) => f.path).toSet(), before);
  });

  test(
      'CPU transparent snapshot fails before commit while GPU cap pixels have alpha zero',
      () async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    final state = snapshot(module, module.defaultPreset.params, true);
    final cpu = FibonacciComplexExportCapture(
        snapshot: state, requiresCpu: true, width: 32, height: 24);
    SharedPreferences.setMockInitialValues({});
    final root = await Directory(
            Platform.environment['TMPDIR'] ?? Directory.systemTemp.path)
        .createTemp('fib-alpha-');
    addTearDown(() => root.delete(recursive: true));
    final service = ExportService(coordinator: ExportCoordinator());
    await service.setPreferredExportDirectory(root);
    await expectLater(
        service.withCapture(cpu.capturePng).exportWithOptions(GlobalKey(),
            options: const ExportOptions(
                resolution: ExportResolution.custom,
                customWidth: 32,
                customHeight: 24,
                transparentBackground: true),
            screenWidth: 32,
            screenHeight: 24,
            fractalType: module.id,
            parameters: state.state.params),
        throwsA(isA<FibonacciComplexCpuTransparencyException>()));
    expect(root.listSync(), isEmpty);
    final gpu = FibonacciComplexExportCapture(
        snapshot: state, requiresCpu: false, width: 32, height: 24);
    final decoded = img.decodePng(await gpu.capturePng(1))!;
    expect(decoded.every((p) => p.a == 0 || p.a == 255), isTrue);
    expect(decoded.any((p) => p.a == 0), isTrue);
    expect(decoded.any((p) => p.a == 255), isTrue);
  });

  testWidgets('landscape CPU pane and split export retain the actual viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final registry = ModuleRegistry();
    final module = registry.byId('fibonacci_complex_julia');
    final controller = FractalController(registry)
      ..selectModule(module, animate: false);
    addTearDown(controller.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(home: CpuFallbackPane(boundaryKey: boundary))));
    final cpu =
        tester.widget<CpuFractalRenderer>(find.byType(CpuFractalRenderer));
    expect(cpu.width / cpu.height, 2);
    final wide = FibonacciComplexExportCapture.fromBoundary(
        snapshot: snapshot(module, controller.params, false),
        requiresCpu: true,
        boundaryKey: boundary);
    expect([wide.width, wide.height], [800, 400]);
    // Same screen, renderer occupies only the left pane (compare/Fourier split).
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
            home: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: 400,
                    height: 400,
                    child: CpuFallbackPane(boundaryKey: boundary))))));
    final split = FibonacciComplexExportCapture.fromBoundary(
        snapshot: snapshot(module, controller.params, false),
        requiresCpu: true,
        boundaryKey: boundary);
    expect([split.width, split.height], [400, 400]);
    expect(
        tester
                .widget<CpuFractalRenderer>(find.byType(CpuFractalRenderer))
                .width /
            tester
                .widget<CpuFractalRenderer>(find.byType(CpuFractalRenderer))
                .height,
        1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'viewer visibly refuses CPU-only transparent Fibonacci export before saving',
      (tester) async {
    Future<void> settleUi() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    SharedPreferences.setMockInitialValues(
        {'renderer_backend_mode': 'cpuOnly'});
    final registry = ModuleRegistry();
    final controller = FractalController(registry)
      ..selectModule(registry.byId('fibonacci_complex_julia'), animate: false);
    final settings = await RendererSettingsService.create();
    final presets = await PresetStore.create();
    final history = HistoryProvider(store: await HistoryStore.create());
    addTearDown(() {
      controller.dispose();
      settings.dispose();
      history.dispose();
    });
    for (final locale in const [Locale('en'), Locale('es')]) {
      await tester.pumpWidget(MultiProvider(
          providers: [
            Provider.value(value: registry),
            ChangeNotifierProvider.value(value: controller),
            ChangeNotifierProvider.value(value: settings),
            Provider.value(value: presets),
            ChangeNotifierProvider.value(value: history),
          ],
          child: MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const FractalViewerScreen(restoreViewerSession: false))));
      await settleUi();
      await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
      await settleUi();
      await tester
          .tap(find.text(locale.languageCode == 'es' ? 'Exportar' : 'Export'));
      await settleUi();
      final transparent = find
          .text(locale.languageCode == 'es' ? 'Transparente' : 'Transparent');
      await tester.ensureVisible(transparent);
      await settleUi();
      await tester.tap(transparent);
      await settleUi();
      await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
      await settleUi();
      expect(
          find.textContaining(locale.languageCode == 'es'
              ? 'La salida CPU solo tiene RGB'
              : 'CPU output is RGB only'),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
