import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_offscreen_renderer.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../../test/migration/support/baseline_inventory.dart';
import '../../test/migration/support/reference_capture.dart'
    show captureReferenceSources, referenceHash;
import '../../test/migration/support/visual_presentation_evolution.dart';
import '../helpers/linux_audit_visual_metrics.dart';

const _timing = bool.fromEnvironment('VISUAL_RICHNESS_TIMING');

// FractalPreset's serializer snapshots nested parameter collections and vectors.
FractalRenderSnapshot _freeze(FractalRenderSnapshot live) {
  final preset = FractalPreset.fromJson(jsonDecode(jsonEncode(FractalPreset(
    id: 'capture',
    moduleId: live.module.id,
    name: 'capture',
    params: live.state.params,
    view: live.state.view,
    createdAt: DateTime.utc(2026),
  ).toJson())) as Map<String, dynamic>);
  return FractalRenderSnapshot(
    module: live.module,
    state: FractalRenderState(
        params: preset.params,
        view: preset.view,
        transparentBackground: live.state.transparentBackground),
    time: live.time,
    glowEnabled: live.glowEnabled,
    glowSigma: live.glowSigma,
    glowIntensity: live.glowIntensity,
    kaleidoscopeEnabled: live.kaleidoscopeEnabled,
    kaleidoscopeSectors: live.kaleidoscopeSectors,
    kaleidoscopeMirror: live.kaleidoscopeMirror,
    kaleidoscopeRotation: live.kaleidoscopeRotation,
    kaleidoscopeMirrorMode: live.kaleidoscopeMirrorMode,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'five-ID production presentation capture and completed-readback timing',
      (tester) async {
    final output = Directory(Platform.environment['VISUAL_RICHNESS_OUT'] ??
        'build/test_output/visual-richness');
    output.createSync(recursive: true);
    final records = <Map<String, Object?>>[];
    final failures = <String>[];
    final selectedStates = [
      for (final id in visualPilotIds)
        for (final edited in [false, true])
          for (final size in [256, 512])
            for (final transparent in [false, true])
              '$id-${edited ? 'edited' : 'default'}-$size-${transparent ? 'transparent' : 'opaque'}',
    ];
    final selected = selectedStates.length;
    expect(visualPilotIds, hasLength(5));
    expect(selectedStates.toSet(), hasLength(40));
    var rendered = 0;
    final report = <String, Object?>{
      'schema': 1,
      'kind': 'visual-presentation-candidate-capture',
      'qualification':
          'Measured candidate evidence, not historical equality or hardware qualification.',
      'timing_enabled': _timing,
      'selected_states': selectedStates,
      'records': records,
      'failures': failures,
    };
    // Write accounting even on setup/plugin/shader failure. Never skip the test.
    try {
      expect(RuntimeModeService.forceGpuRender, isTrue,
          reason: 'Run with --dart-define=FORCE_GPU_RENDER=true');
      expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
      SharedPreferences.setMockInitialValues({});
      final accessibility = await AccessibilityService.create();
      final settings = await RendererSettingsService.create();
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);
      final replay = FourierOffscreenRenderer(); // Reused across all draws.
      final inventory = buildBaselineInventory();
      final sources = captureReferenceSources(
          (inventory['modules']!['provenance'] as Map)['sources'] as Map,
          additionalRoots: [
            'integration_test/catalog/visual_richness_pilot_test.dart'
          ]);
      report['source_bindings'] = sources;
      report['source_set_sha256'] = visualHash(sources);
      report['source_revision'] =
          (Process.runSync('git', ['rev-parse', 'HEAD']).stdout as String)
              .trim();
      report['runtime'] = {
        'os': Platform.operatingSystem,
        'dart': Platform.version,
        'flutter': File('fdroid/flutter.version').readAsStringSync().trim(),
        'requested_backend': 'FORCE_GPU_RENDER',
        'hardware_gpu': 'not inferred; platform lane must record driver/device'
      };

      Future<(Uint8List, Uint8List)> draw(
          FractalRenderSnapshot snapshot, int size,
          {bool encode = true, Stopwatch? timing}) async {
        timing?.start();
        final image =
            await replay.render(snapshot: snapshot, width: size, height: size);
        try {
          final data =
              await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          timing?.stop();
          if (data == null) throw StateError('Missing raw RGBA readback');
          final rgba = Uint8List.fromList(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          final png = encode
              ? await image.toByteData(format: ui.ImageByteFormat.png)
              : null;
          if (encode && png == null) throw StateError('Missing PNG readback');
          return (
            rgba,
            png == null
                ? Uint8List(0)
                : Uint8List.fromList(png.buffer
                    .asUint8List(png.offsetInBytes, png.lengthInBytes))
          );
        } finally {
          image.dispose();
        }
      }

      for (final id in visualPilotIds) {
        final module = controller.registry.byId(id);
        for (final edited in [false, true]) {
          final preset = module.defaultPreset;
          final view = edited
              ? preset.view.copyWith(
                  zoom: preset.view.zoom * 1.2,
                  pan: preset.view.pan + Vector2(0.05, -0.03),
                  rotation: preset.view.rotation + Vector3(0.1, 0.15, 0),
                )
              : preset.view;
          for (final size in [256, 512]) {
            for (final transparent in [false, true]) {
              final key =
                  '$id-${edited ? 'edited' : 'default'}-$size-${transparent ? 'transparent' : 'opaque'}';
              try {
                expect(
                    await controller.loadState(
                        module: module,
                        params: preset.params,
                        view: view,
                        transparentBackground: transparent),
                    isTrue);
                final sink = FractalRenderSnapshotSink();
                await binding
                    .setSurfaceSize(Size(size.toDouble(), size.toDouble()));
                await tester.pumpWidget(MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: controller),
                      ChangeNotifierProvider.value(value: accessibility),
                      ChangeNotifierProvider.value(value: settings),
                    ],
                    child: MaterialApp(
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: FractalRenderer(
                          key: ValueKey(key),
                          renderSnapshotSink: sink,
                          animationEnabled: false,
                          gesturesEnabled: false,
                          showRendererIndicator: false),
                    )));
                for (var i = 0; i < 100 && sink.snapshot == null; i++) {
                  await tester.pump(const Duration(milliseconds: 50));
                }
                expect(sink.snapshot, isNotNull,
                    reason:
                        '$key missing shader/effective GPU snapshot (not skipped)');
                final snapshot = _freeze(sink.snapshot!);
                expect(snapshot.module.id, id);
                expect(snapshot.time, 0);
                expect(snapshot.state.transparentBackground, transparent);
                final (rgba, png) = await draw(snapshot, size);
                expect(rgba, hasLength(size * size * 4));
                final alpha = <int, int>{};
                for (var i = 3; i < rgba.length; i += 4) {
                  alpha.update(rgba[i], (n) => n + 1, ifAbsent: () => 1);
                }
                expect(alpha.keys.any((a) => a > 0), isTrue,
                    reason: '$key empty output');
                if (!transparent) expect(alpha.keys, [255]);
                final decoded = img.decodePng(png)!;
                expect(decoded.width, size);
                expect(decoded.height, size);
                final export = await const ExportService()
                    .withCapture((_) async => png)
                    .captureWithOptions(GlobalKey(),
                        options: ExportOptions(
                            format: ExportFormat.png,
                            resolution: ExportResolution.custom,
                            customWidth: size,
                            customHeight: size,
                            transparentBackground: transparent),
                        screenWidth: size.toDouble(),
                        screenHeight: size.toDouble());
                final exported = img.decodePng(export)!;
                expect(exported.width, size);
                expect(exported.height, size);
                expect(exported.getBytes(order: img.ChannelOrder.rgba),
                    decoded.getBytes(order: img.ChannelOrder.rgba),
                    reason: '$key decoded PNG export matches frozen draw');
                await File('${output.path}/$key.png').writeAsBytes(png);
                await File('${output.path}/$key-export.png')
                    .writeAsBytes(export);
                final state = FractalPreset(
                        id: key,
                        moduleId: snapshot.module.id,
                        name: key,
                        params: snapshot.state.params,
                        view: snapshot.state.view,
                        createdAt: DateTime.utc(2026))
                    .toJson()
                  ..remove('createdAt');
                final record = <String, Object?>{
                  'id': key,
                  'requested_module': id,
                  'effective_module': snapshot.module.id,
                  'effective_backend': 'FragmentProgram/FractalCanvas',
                  'shader_asset': snapshot.module.shaderAsset,
                  'shader_source_sha256': sources[snapshot.module.shaderAsset],
                  'source_set_sha256': report['source_set_sha256'],
                  'requested_state': preset.copyWith(view: view).toJson()
                    ..remove('createdAt'),
                  'state': state,
                  'time': snapshot.time,
                  'transparent_background':
                      snapshot.state.transparentBackground,
                  'effects': {
                    'glow_enabled': snapshot.glowEnabled,
                    'glow_sigma': snapshot.glowSigma,
                    'glow_intensity': snapshot.glowIntensity,
                    'kaleidoscope_enabled': snapshot.kaleidoscopeEnabled,
                    'kaleidoscope_sectors': snapshot.kaleidoscopeSectors,
                    'kaleidoscope_mirror': snapshot.kaleidoscopeMirror,
                    'kaleidoscope_rotation': snapshot.kaleidoscopeRotation,
                    'kaleidoscope_mirror_mode': snapshot.kaleidoscopeMirrorMode
                  },
                  'width': size,
                  'height': size,
                  'rgba_sha256': referenceHash(rgba),
                  'png_sha256': referenceHash(png),
                  'export_png_sha256': referenceHash(export),
                  'png_decoded_rgba_sha256': referenceHash(
                      decoded.getBytes(order: img.ChannelOrder.rgba)),
                  'alpha_histogram': {
                    for (final entry in alpha.entries)
                      '${entry.key}': entry.value
                  },
                  'visual_signals': linuxAuditVisualSignals(decoded),
                };
                if (_timing && size == 512) {
                  // Compilation/program load already completed. Every sample is
                  // a fresh render plus awaited raw readback, never a ticker/cache.
                  for (var i = 0; i < 10; i++) {
                    await draw(snapshot, 512, encode: false);
                  }
                  final samples = <double>[];
                  for (var i = 0; i < 60; i++) {
                    final watch = Stopwatch();
                    await draw(snapshot, 512, encode: false, timing: watch);
                    samples.add(watch.elapsedMicroseconds / 1000);
                  }
                  samples.sort();
                  record['timing_ms'] = {
                    'warmups': 10,
                    'completed': samples.length,
                    'median': (samples[29] + samples[30]) / 2,
                    'p95': samples[56],
                    'sorted_samples': samples
                  };
                }
                records.add(record);
                rendered++;
              } catch (error, stack) {
                failures.add('$key: $error\n$stack');
              }
            }
          }
        }
      }
    } catch (error, stack) {
      failures.add('setup: $error\n$stack');
    } finally {
      report['counts'] = {
        'selected': selected,
        'rendered': rendered,
        'failed': selected - rendered,
        'skipped': 0
      };
      report['unrendered_states'] = selectedStates
          .where((id) => !records.any((record) => record['id'] == id))
          .toList();
      await File('${output.path}/manifest.json')
          .writeAsString(canonicalJson(report));
      await tester.pumpWidget(const SizedBox.shrink());
      await binding.setSurfaceSize(null);
    }
    validateVisualCaptureCounts(
        selected: selected,
        rendered: rendered,
        failed: selected - rendered,
        skipped: 0);
    expect(tester.takeException(), isNull, reason: 'No hidden renderer errors');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
