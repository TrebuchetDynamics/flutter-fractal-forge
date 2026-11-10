import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Reuse the locked hashing dependency, as in baseline_inventory.dart.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/attractor_trajectory.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/number_walls/number_wall_presentation.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/attractor_trajectory_canvas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart';

import 'baseline_inventory.dart';
import 'reference_source_transition.dart';

const referenceOutput = String.fromEnvironment('MIGRATION_REFERENCE_OUT');
const referenceCompare = String.fromEnvironment('MIGRATION_REFERENCE_COMPARE');
const referenceRoot = 'migration/baseline/reference-renders';
const referenceStates = [
  'mandelbrot',
  'julia',
  'burning_ship',
  'newton_z3',
  'lorenz_2d',
  'sierpinski_triangle',
  'number_wall',
  'mandelbulb',
  'milnor_brieskorn',
  'mandelbrot-edited',
  'mandelbulb-edited',
];
const referenceSize = ui.Size(256, 256);

String referenceHash(List<int> bytes) => sha256.convert(bytes).toString();
String objectHash(Object? value) =>
    referenceHash(utf8.encode(canonicalJson(value)));
Map<String, dynamic> readManifest(String directory) =>
    jsonDecode(File('$directory/manifest.json').readAsStringSync())
        as Map<String, dynamic>;

FractalPreset referencePreset(FractalModule module, String stateId) {
  // The controller fills omitted preset fields from the module schema.
  final preset = module.defaultPreset.copyWith(params: {
    for (final parameter in module.parameters)
      parameter.id: parameter.defaultValue,
    ...module.defaultPreset.params,
  });
  return switch (stateId) {
    'mandelbrot-edited' => preset.copyWith(
        view: preset.view.copyWith(pan: Vector2(-0.55, 0.12), zoom: 3)),
    'mandelbulb-edited' => preset.copyWith(
        view: preset.view.copyWith(
            pan: Vector2(0.1, -0.08),
            zoom: 1.4,
            rotation: Vector3(0.25, 0.65, 0.1))),
    _ => preset,
  };
}

Map<String, Object?> referenceInputs(
        FractalModule module, FractalPreset preset) =>
    {
      'module_id': module.id,
      'shader_asset': module.shaderAsset,
      'params': preset.params,
      'view': preset.toJson()['view'],
      'width': 256,
      'height': 256,
      'time': 0,
      'transparent_background': false,
      'glow_enabled': false,
      'kaleidoscope_enabled': false,
    };

/// Same real uniform/draw/readback seam as catalog_preset_render_health_test.
/// Number Walls instead consumes the controller's certified grid with the shared
/// exact Canvas display/export painter, never its placeholder module shader.
/// Trajectory views use the production finite RK4 model and Canvas painter.
Future<Uint8List> drawReference(
    FractalModule module, FractalPreset preset) async {
  ui.FragmentShader? shader;
  FractalController? controller;
  ui.Picture? picture;
  ui.Image? frame;
  try {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    if (module.id == 'number_wall') {
      controller = FractalController(ModuleRegistry());
      expect(
          await controller.loadState(
              module: module, params: preset.params, view: preset.view),
          isTrue);
      expect(controller.module.id, module.id);
      expect(controller.params, preset.params);
      expect(controller.numberWallPending, isFalse);
      expect(controller.numberWallStatus, NumberWallPrimeStatus.verifiedPrime);
      expect(controller.numberWallGrid, isNotNull);
      final grid = controller.numberWallGrid!;
      expect(grid.prime.toString(), preset.params['prime']);
      expect(grid.rowCount, preset.params['rows']);
      expect(grid.columnCount, preset.params['columns']);
      expect(grid.columnStart, preset.params['columnStart']);
      expect(preset.copyWith(view: controller.view).toJson()['view'],
          preset.toJson()['view']);
      expect(controller.transparentBackground, isFalse);
      NumberWallPainter(
              grid: controller.numberWallGrid!,
              style: NumberWallStyle.fromParams(controller.params),
              view: controller.view)
          .paint(canvas, referenceSize);
    } else if (preset.view.trajectory case final settings?) {
      controller = FractalController(ModuleRegistry());
      expect(
          await controller.loadState(
              module: module, params: preset.params, view: preset.view),
          isTrue);
      expect(controller.module.id, module.id);
      expect(controller.params, preset.params);
      expect(controller.view.trajectory!.toJson(), settings.toJson());
      expect(controller.glowEnabled, isFalse);
      expect(controller.kaleidoscopeEnabled, isFalse);
      final trajectory = (await AttractorTrajectoryModel.generateAsync(settings,
          cancellation: AttractorTrajectoryCancellation()))!;
      expect(trajectory.settings.toJson(), settings.toJson());
      expect(trajectory.points.length, settings.retainedSteps);
      expect(trajectory.bounds.isFinite, isTrue);
      expect(trajectory.points.every((p) => p.isFinite), isTrue);
      AttractorTrajectoryPainter(
              trajectory: trajectory,
              view: controller.view,
              colorScheme: (controller.params['colorScheme'] as num).round(),
              transparentBackground: false,
              glowEnabled: controller.glowEnabled,
              glowSigma: controller.glowSigma,
              glowIntensity: controller.glowIntensity,
              kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
              kaleidoscopeSectors: controller.kaleidoscopeSectors,
              kaleidoscopeMirror: controller.kaleidoscopeMirror,
              kaleidoscopeRotation: controller.kaleidoscopeRotation,
              kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode)
          .paint(canvas, referenceSize);
    } else {
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      shader = program.fragmentShader();
      module.setUniforms(
          shader,
          FractalRenderState(
              params: preset.params,
              view: preset.view,
              transparentBackground: false),
          referenceSize,
          0);
      canvas.drawRect(
          ui.Offset.zero & referenceSize, ui.Paint()..shader = shader);
    }
    picture = recorder.endRecording();
    frame = await picture.toImage(256, 256);
    expect(frame.width, 256);
    expect(frame.height, 256);
    final bytes = (await frame.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    return Uint8List.fromList(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
  } finally {
    frame?.dispose();
    picture?.dispose();
    shader?.dispose();
    controller?.dispose();
  }
}

img.Image rgbaImage(Uint8List rgba) => img.Image.fromBytes(
    width: 256,
    height: 256,
    bytes: rgba.buffer,
    bytesOffset: rgba.offsetInBytes,
    numChannels: 4);

void validateRgba(Uint8List rgba) {
  expect(rgba.length, 256 * 256 * 4);
  expect({for (var i = 3; i < rgba.length; i += 4) rgba[i]}, {255});
  // Integer RGBA8 readback is finite by construction; this is health, not math.
  expect(RenderAuditMetrics.fromImage(rgbaImage(rgba)).verdict, 'pass');
}

Uint8List readReferencePng(String directory, Map record) {
  final bytes = File('$directory/${record['file']}').readAsBytesSync();
  expect(record['file'], '${record['state_id']}.png');
  expect(referenceHash(bytes), record['png_sha256']);
  expect(record['pixel_format'], 'RGBA8');
  expect(record['alpha'], 'opaque');
  final decoded = img.decodePng(bytes)!;
  expect(decoded.width, record['inputs']['width']);
  expect(decoded.height, record['inputs']['height']);
  expect(decoded.numChannels, 4);
  final rgba = decoded.getBytes(order: img.ChannelOrder.rgba);
  validateRgba(rgba);
  expect(referenceHash(rgba), record['rgba_sha256']);
  expect(objectHash(record['inputs']), record['input_sha256']);
  expect(RenderAuditMetrics.fromImage(decoded).toJson(), record['health']);
  return rgba;
}

/// Descriptive same-backend variance only: no hardware parity threshold.
Map<String, Object> referenceVariance(Uint8List a, Uint8List b) {
  expect(a.length, b.length);
  var changedPixels = 0, maxDelta = 0, totalDelta = 0;
  for (var i = 0; i < a.length; i += 4) {
    var changed = false;
    for (var c = 0; c < 4; c++) {
      final delta = (a[i + c] - b[i + c]).abs();
      if (delta > 0) changed = true;
      if (delta > maxDelta) maxDelta = delta;
      totalDelta += delta;
    }
    if (changed) changedPixels++;
  }
  return {
    'equal': changedPixels == 0,
    'changed_pixels': changedPixels,
    'max_channel_delta': maxDelta,
    'mean_absolute_channel_delta': totalDelta / a.length
  };
}

Map<String, String> captureReferenceSources(Map baselineSources) {
  final hashes = Map<String, String>.from(baselineSources);
  final visited = <String>{};
  void visit(String path) {
    if (!visited.add(path)) return;
    final source = File(path).readAsStringSync();
    hashes[path] = referenceHash(utf8.encode(source));
    for (final match in RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''')
        .allMatches(
            source.replaceAll(RegExp(r'/\*[\s\S]*?\*/|//[^\n]*'), ''))) {
      final uri = match[1]!;
      if (uri.startsWith('package:flutter_fractals/')) {
        visit(uri.replaceFirst('package:flutter_fractals/', 'lib/'));
      } else if (!uri.contains(':')) {
        visit(File.fromUri(File(path).uri.resolve(uri)).path);
      }
    }
  }

  visit('test/migration/reference_render_test.dart');
  visit('lib/features/renderer/widgets/renderer/fractal_renderer.dart');
  return hashes;
}

class ReferenceCapture {
  final inventory = buildBaselineInventory();
  final records = <Map<String, Object?>>[];
  late final Map<String, Object?> provenance;
  late final Map<String, Object?> backend;
  Map<String, dynamic>? retained;
  Map<String, dynamic>? comparison;
  String comparisonDirectory = referenceCompare;

  void prepare() {
    final baselineHashes = <String, String>{};
    for (final name in baselineNames) {
      final file = File('migration/baseline/$name.json');
      expect(canonicalJson(inventory[name]), file.readAsStringSync(),
          reason: '$name baseline drift');
      baselineHashes[name] = referenceHash(file.readAsBytesSync());
    }
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    // Linux capture evidence: observed tester flags, not a claimed GPU vendor.
    // shortcut: /proc identifies this backend; extend before capturing elsewhere.
    final flags = File('/proc/self/cmdline').readAsStringSync().split('\u0000');
    expect(flags, contains('--enable-software-rendering'));
    expect(flags, contains('--skia-deterministic-rendering'));
    backend = {
      'renderer': 'Flutter tester / Skia software runtime effects and Canvas',
      'software': true,
      'os': Platform.operatingSystem,
      'flags': flags
          .where((f) =>
              f == '--enable-software-rendering' ||
              f == '--skia-deterministic-rendering')
          .toList()
        ..sort(),
      'flutter_tester_sha256':
          referenceHash(File(Platform.resolvedExecutable).readAsBytesSync()),
    };
    final sources = captureReferenceSources(
        (inventory['modules']!['provenance'] as Map)['sources'] as Map);
    provenance = {
      'source_revision':
          (Process.runSync('git', ['rev-parse', 'HEAD']).stdout as String)
              .trim(),
      'source_bindings': sources,
      'source_set_sha256': objectHash(sources),
      'baseline_files_sha256': baselineHashes,
      'flutter': jsonDecode(
          File('$sdk/bin/cache/flutter.version.json').readAsStringSync()),
      'dart': Platform.version,
      'backend': backend,
      'backend_sha256': objectHash(backend),
      'qualification':
          'Offline software image health only; no mathematical, hardware, device or platform qualification.',
    };
    if (referenceOutput.isNotEmpty) {
      final directory = Directory(referenceOutput);
      if (!directory.isAbsolute)
        throw ArgumentError('Capture output must be absolute');
      directory.createSync(recursive: true);
      final root = Directory.current.resolveSymbolicLinksSync();
      final resolved = directory.resolveSymbolicLinksSync();
      if (resolved == root || resolved.startsWith('$root/')) {
        throw ArgumentError('Capture output must be outside the checkout');
      }
      if (directory.listSync().isNotEmpty)
        throw StateError('Capture output must be empty');
    } else {
      retained = readManifest(referenceRoot);
      validateManifest(retained!);
      validateReferenceSourceTransition(
        transition: readReferenceSourceTransition(),
        retainedSources: retained!['provenance']['source_bindings'] as Map,
        currentSources: sources,
        fixtureHashes: referenceFixtureHashes(),
      );
      expect(retained!['provenance']['baseline_files_sha256'], baselineHashes);
      comparisonDirectory = '$referenceRoot/first-capture';
    }
    if (comparisonDirectory.isNotEmpty) {
      comparison = readManifest(comparisonDirectory);
      validateManifest(comparison!);
      expect(comparison!['provenance']['backend_sha256'],
          retained?['provenance']['backend_sha256'] ?? objectHash(backend),
          reason: 'Variance must compare the same backend');
      if (retained == null) {
        expect(comparison!['provenance']['source_bindings'], sources);
      } else {
        validateReferenceSourceTransition(
          transition: readReferenceSourceTransition(),
          retainedSources: comparison!['provenance']['source_bindings'] as Map,
          currentSources: sources,
          fixtureHashes: referenceFixtureHashes(),
        );
      }
      expect(comparison!['provenance']['flutter'],
          retained?['provenance']['flutter'] ?? provenance['flutter']);
      expect(comparison!['provenance']['dart'],
          retained?['provenance']['dart'] ?? provenance['dart']);
      expect(
          comparison!['provenance']['baseline_files_sha256'], baselineHashes);
    }
  }

  void validateManifest(Map manifest) {
    expect(manifest['schema'], 1);
    expect(manifest['kind'], 'reference-renders');
    expect((manifest['records'] as List).map((r) => r['state_id']),
        referenceStates);
    expect(objectHash(manifest['provenance']['backend']),
        manifest['provenance']['backend_sha256']);
    expect(objectHash(manifest['provenance']['source_bindings']),
        manifest['provenance']['source_set_sha256']);
  }

  Map baselineRecord(String kind, String id) =>
      ((inventory[kind]!['payload'] as Map)['records'] as List).singleWhere(
          (r) => r[kind == 'modules' ? 'id' : 'module_id'] == id) as Map;

  void accept(String stateId, FractalModule module, FractalPreset preset,
      Uint8List rgba) {
    validateRgba(rgba);
    final inputs = referenceInputs(module, preset);
    final png = Uint8List.fromList(img.encodePng(rgbaImage(rgba)));
    final record = <String, Object?>{
      'state_id': stateId,
      'file': '$stateId.png',
      'inputs': inputs,
      'input_sha256': objectHash(inputs),
      'path': module.id == 'number_wall'
          ? 'certified-grid/NumberWallPainter/Canvas'
          : preset.view.trajectory != null
              ? 'finite-RK4/AttractorTrajectoryPainter/Canvas'
              : 'FragmentProgram/module.setUniforms',
      'mathematics': baselineRecord('capabilities', module.id)['mathematics'],
      'health': RenderAuditMetrics.fromImage(rgbaImage(rgba)).toJson(),
      'png_sha256': referenceHash(png),
      'rgba_sha256': referenceHash(rgba),
      'pixel_format': 'RGBA8',
      'alpha': 'opaque',
      if (module.id != 'number_wall' && preset.view.trajectory == null)
        'compiled_shader_sha256': referenceHash(
            File('build/unit_test_assets/${module.shaderAsset}')
                .readAsBytesSync()),
    };
    if (stateId.endsWith('-edited')) {
      final initial = records.singleWhere((r) => r['state_id'] == module.id);
      expect(record['rgba_sha256'], isNot(initial['rgba_sha256']),
          reason: '$stateId must actually change the rendered view');
    }
    if (retained != null) {
      final old = (retained!['records'] as List)
          .singleWhere((r) => r['state_id'] == stateId) as Map;
      for (final key in ['inputs', 'input_sha256', 'path', 'mathematics']) {
        expect(record[key], old[key], reason: '$stateId $key');
      }
      final variance =
          referenceVariance(readReferencePng(referenceRoot, old), rgba);
      // This transition qualifies only the retained same-backend image contract.
      expect(objectHash(backend), retained!['provenance']['backend_sha256']);
      expect(variance['equal'], isTrue,
          reason: '$stateId clock seam must preserve same-backend pixels');
      for (final key in [
        'health',
        'png_sha256',
        'rgba_sha256',
        'pixel_format',
        'alpha',
        'compiled_shader_sha256'
      ]) {
        expect(record[key], old[key], reason: '$stateId retained $key');
      }
      print('$stateId retained comparison: ${canonicalJson(variance).trim()}');
    }
    if (referenceOutput.isNotEmpty) {
      File('$referenceOutput/$stateId.png').writeAsBytesSync(png);
      expect(readReferencePng(referenceOutput, record), orderedEquals(rgba));
    }
    if (comparison != null) {
      final old = (comparison!['records'] as List)
          .singleWhere((r) => r['state_id'] == stateId) as Map;
      expect(old['inputs'], inputs);
      final target = retained == null
          ? record
          : (retained!['records'] as List)
              .singleWhere((r) => r['state_id'] == stateId) as Map;
      for (final key in ['path', 'mathematics', 'compiled_shader_sha256']) {
        expect(old[key], target[key], reason: '$stateId comparison $key');
      }
      final measured = {
        'reference_manifest_sha256': referenceHash(
            File('$comparisonDirectory/manifest.json').readAsBytesSync()),
        'reference_rgba_sha256': old['rgba_sha256'],
        'png_equal': old['png_sha256'] == target['png_sha256'],
        ...referenceVariance(readReferencePng(comparisonDirectory, old),
            retained == null ? rgba : readReferencePng(referenceRoot, target)),
      };
      if (retained == null) {
        record['same_backend_comparison'] = measured;
      } else {
        expect(target['same_backend_comparison'], measured);
      }
    }
    records.add(record);
  }

  void finish() {
    expect(records.map((r) => r['state_id']), referenceStates);
    if (referenceOutput.isEmpty) return;
    final document = {
      'schema': 1,
      'kind': 'reference-renders',
      'provenance': provenance,
      'records': records
    };
    validateManifest(document);
    File('$referenceOutput/manifest.json')
        .writeAsStringSync(canonicalJson(document));
    expect(readManifest(referenceOutput), document);
  }
}
