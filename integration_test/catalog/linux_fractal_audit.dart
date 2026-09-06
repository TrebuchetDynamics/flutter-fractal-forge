// Standalone profile-mode Linux audit app; launched by scripts/audit-linux-fractals.py.
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

import '../helpers/linux_audit_visual_metrics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isLinux || !kProfileMode) {
    stderr.writeln('This audit requires a Linux profile build.');
    exit(2);
  }
  final output = Directory(Platform.environment['FRACTAL_AUDIT_OUTPUT']!);
  output.createSync(recursive: true);
  final registry = ModuleRegistry();
  final modules = registry.modules
      .where((m) =>
          !m.shaderAsset.startsWith('shaders/diagnostic/') &&
          m.id != 'hydrogen_orbital')
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  final l10n = await AppLocalizations.delegate.load(const Locale('en'));
  File('${output.path}/manifest.json').writeAsStringSync(jsonEncode([
    for (final m in modules)
      {
        'id': m.id,
        'name': m.displayName(l10n),
        'shader': m.shaderAsset,
        'dimension': m.dimension.name,
      },
  ]));
  if (Platform.environment['FRACTAL_AUDIT_LIST_ONLY'] == '1') exit(0);
  // Keep user palettes/settings out of the audit and leave their storage alone.
  SharedPreferences.setMockInitialValues({});
  await PaletteService.create();
  final only = Platform.environment['FRACTAL_AUDIT_ONLY']?.split(',').toSet();
  final size = int.parse(Platform.environment['FRACTAL_AUDIT_SIZE'] ?? '320');
  final samples =
      int.parse(Platform.environment['FRACTAL_AUDIT_FRAMES'] ?? '20');
  final boundary = GlobalKey();
  final sink = FractalRenderSnapshotSink();
  final controller = FractalController(registry);
  final errors = <String>[];
  FlutterError.onError = (details) => errors.add(details.exceptionAsString());
  final timings =
      File('${output.path}/timings.jsonl').openSync(mode: FileMode.append);
  void recordTimings(List<ui.FrameTiming> batch) {
    for (final t in batch) {
      timings.writeStringSync('${jsonEncode({
            'startUs': t.timestampInMicroseconds(ui.FramePhase.buildStart),
            'buildMs': t.buildDuration.inMicroseconds / 1000,
            'rasterMs': t.rasterDuration.inMicroseconds / 1000,
            'totalMs': t.totalSpan.inMicroseconds / 1000,
          })}\n');
    }
  }

  WidgetsBinding.instance.addTimingsCallback(recordTimings);
  runApp(MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: size.toDouble(),
            height: size.toDouble(),
            child: ChangeNotifierProvider.value(
              value: controller,
              child: FractalRenderer(
                  boundaryKey: boundary,
                  gesturesEnabled: false,
                  animationEnabled: false,
                  showRendererIndicator: false,
                  renderSnapshotSink: sink),
            ),
          ),
        )),
  ));
  await WidgetsBinding.instance.endOfFrame;
  Object? previousPalette;
  for (final module
      in modules.where((m) => only == null || only.contains(m.id))) {
    File('${output.path}/active.json')
        .writeAsStringSync(jsonEncode({'id': module.id}));
    final result = <String, Object?>{
      'id': module.id,
      'devicePixelRatio': WidgetsBinding
          .instance.platformDispatcher.views.first.devicePixelRatio,
      'views': <Object>[],
      'errors': errors
    };
    errors.clear();
    final load = Stopwatch()..start();
    try {
      sink.snapshot = null;
      controller.selectModule(module, animate: false);
      controller.applyPreset(module.defaultPreset);
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (sink.snapshot?.module.id != module.id) {
        if (errors.isNotEmpty) throw StateError(errors.join('\n'));
        if (DateTime.now().isAfter(deadline))
          throw StateError('No production GPU snapshot within 30 seconds');
        await Future<void>.delayed(const Duration(milliseconds: 16));
        await WidgetsBinding.instance.endOfFrame;
      }
      result['loadMs'] = load.elapsedMicroseconds / 1000;
      // Finish palette interpolation before capturing deterministic default art.
      if (previousPalette != controller.params['colorScheme']) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
      previousPalette = controller.params['colorScheme'];
      for (var warmup = 0; warmup < 3; warmup++) {
        controller.updateZoom(controller.view.zoom);
        await WidgetsBinding.instance.endOfFrame;
      }
      final views = result['views']! as List<Object>;
      views.add(await _capture(
          boundary, output, module.id, 'default', size, sink.snapshot!));
      final baseZoom = controller.view.zoom;
      result['measureStartUs'] = developer.Timeline.now;
      final wall = Stopwatch()..start();
      for (var frame = 0; frame < samples; frame++) {
        controller.updateZoom(baseZoom * (1 + (frame.isEven ? 0.002 : 0.004)));
        await WidgetsBinding.instance.endOfFrame;
      }
      result['measureEndUs'] = developer.Timeline.now;
      result['requestedFrames'] = samples;
      result['interactionWallMs'] = wall.elapsedMicroseconds / 1000;
      controller.applyPreset(module.defaultPreset);
      final alternatives = module.builtInPresets
          .where((p) => isDistinctAuditPreset(module.defaultPreset, p));
      if (alternatives.isNotEmpty) {
        controller.applyPreset(alternatives.first);
        result['alternatePreset'] = alternatives.first.id;
      } else {
        controller.updateZoom(baseZoom * 0.75);
        result['alternatePreset'] = 'default at 0.75x zoom';
      }
      if (previousPalette != controller.params['colorScheme']) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
      previousPalette = controller.params['colorScheme'];
      // Force a settled paint even when the static renderer has stopped ticking.
      controller.updateZoom(controller.view.zoom);
      await WidgetsBinding.instance.endOfFrame;
      views.add(await _capture(
          boundary, output, module.id, 'alternate', size, sink.snapshot!));
      result['status'] = errors.isEmpty ? 'rendered' : 'error';
    } catch (error, stack) {
      result['status'] = 'error';
      result['error'] = '$error';
      result['stack'] = '$stack';
    }
    File('${output.path}/results.jsonl').writeAsStringSync(
        '${jsonEncode(result)}\n',
        mode: FileMode.append,
        flush: true);
    stdout.writeln('AUDIT ${module.id}: ${result['status']}');
  }
  // Engine timing batches can arrive a second after the frames they describe.
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  WidgetsBinding.instance.removeTimingsCallback(recordTimings);
  timings.closeSync();
  exit(0);
}

Future<Map<String, Object>> _capture(GlobalKey key, Directory output, String id,
    String view, int size, FractalRenderSnapshot snapshot) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  try {
    if (image.width != size || image.height != size) {
      throw StateError(
          'Wrong viewport: ${image.width}x${image.height}; expected ${size}x$size');
    }
    final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    final bytes = png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
    final path = 'images/$id-$view.png';
    File('${output.path}/$path')
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    final decoded = img.decodePng(bytes)!;
    return {
      'view': view,
      'image': path,
      'params': snapshot.state.params,
      'camera': {
        'zoom': snapshot.state.view.zoom,
        'pan': [snapshot.state.view.pan.x, snapshot.state.view.pan.y],
        'rotation': [
          snapshot.state.view.rotation.x,
          snapshot.state.view.rotation.y,
          snapshot.state.view.rotation.z
        ],
      },
      'shaderTime': snapshot.time,
      ...RenderAuditMetrics.fromImage(decoded,
              pngBytes: bytes.length, expectedSize: size)
          .toJson(),
      ...linuxAuditVisualSignals(decoded),
    };
  } finally {
    image.dispose();
  }
}

/// Preset aliases do not provide independent visual coverage.
bool isDistinctAuditPreset(FractalPreset base, FractalPreset candidate) {
  final a = base.view;
  final b = candidate.view;
  return !mapEquals(base.params, {...base.params, ...candidate.params}) ||
      a.zoom != b.zoom ||
      a.pan.x != b.pan.x ||
      a.pan.y != b.pan.y ||
      a.rotation.x != b.rotation.x ||
      a.rotation.y != b.rotation.y ||
      a.rotation.z != b.rotation.z;
}
