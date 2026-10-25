// Real renderer qualification, not a second test marcher. Run with FORCE_GPU_RENDER.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../../test/helpers/sine_sphere_oracle.dart';
import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final evidence = Directory(
    const String.fromEnvironment('SINE_SPHERE_EVIDENCE_DIR').isNotEmpty
        ? const String.fromEnvironment('SINE_SPHERE_EVIDENCE_DIR')
        : '${Directory.systemTemp.path}/sine-sphere-evidence',
  );
  final observations = <String, Object?>{};

  setUpAll(() async {
    await evidence.create(recursive: true);
    observations['platform'] = Platform.operatingSystem;
    observations['backend'] = const String.fromEnvironment(
        'SINE_SPHERE_BACKEND',
        defaultValue: 'unreported (not hardware-qualified)');
    observations['sourceSha256'] = {
      for (final path in [
        'shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_gpu.frag',
        'shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_kernel.glsl',
        'lib/core/modules/fractals/recursive_sine_sphere_module.dart',
        'test/shaders/recursive_sine_sphere_kernel_fixture.frag',
      ])
        path: _sha256(path),
    };
    observations['precision'] = {
      'shader': 'float32; opaque RGBA8 readback, little-endian 24-bit encoding',
      'distanceQuantization': 1e-5,
      'residualQuantization': 1e-6,
      'sphereDistanceTolerance': 5e-4,
      'warpedDistanceTolerance': 5e-4,
      'fieldResidualTolerance': 5e-4,
      'reference':
          'independent double recurrence, 200000 enclosure scan intervals, 64 bisections',
    };
  });

  tearDown(() async {
    await File('${evidence.path}/observations.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(observations));
    debugPrint('SINE_SPHERE_EVIDENCE:${evidence.path}');
  });

  testWidgets('actual production kernel agrees with independent ray oracle',
      (tester) async {
    final samples = <Map<String, Object?>>[];
    Future<void> sample(String name, Vector3 origin, Vector3 direction,
        {int depth = 0,
        double strength = 0.8,
        double phase = 0,
        int budget = 512,
        required int status,
        double? distance}) async {
      final actual = await runSineKernel(
          depth: depth.toDouble(),
          strength: strength,
          radius: 1,
          phase: phase,
          budget: budget.toDouble(),
          origin: origin,
          direction: direction);
      samples.add({
        'name': name,
        'origin': origin.storage.toList(),
        'direction': direction.storage.toList(),
        'depth': depth,
        'strength': strength,
        'radius': 1,
        'phase': phase,
        'budget': budget,
        'status': actual.status,
        'distance': actual.distance,
        'residual': actual.residual,
        'referenceDistance': distance,
      });
      observations['oracleSamples'] = samples;
      expect(actual.status, status, reason: name);
      if (distance != null) {
        expect(actual.distance, closeTo(distance, 5e-4), reason: name);
        expect(actual.residual, lessThanOrEqualTo(5e-4), reason: name);
      }
    }

    // World basis x/y/z, unit rays. These are diagnostic rays, not pixel centers.
    final forward = Vector3(0, 0, -1);
    for (final depth in [0, 3]) {
      final strength = depth == 0 ? 0.8 : 0.0;
      await sample('sphere-$depth-axis', Vector3(0, 0, 3), forward,
          depth: depth, strength: strength, status: 1, distance: 2);
      await sample(
          'sphere-$depth-near-silhouette', Vector3(0.999, 0, 3), forward,
          depth: depth,
          strength: strength,
          status: 1,
          distance: 3 - math.sqrt(1 - 0.999 * 0.999));
      await sample('sphere-$depth-outside', Vector3(1.001, 0, 3), forward,
          depth: depth, strength: strength, status: 0);
    }
    await sample('interior', Vector3.zero(), Vector3(0, 1, 0),
        status: 1, distance: 1);
    await sample('tangent-not-transverse-hit', Vector3(1, 0, 3), forward,
        status: 3, distance: 3);
    for (final fixture in [
      (Vector3(0, 0, 4), (4.0891, 4.0898), 4.089427178194093),
      (Vector3(0.3, -0.4, 4), (3.9890, 3.9897), 3.989350571627848),
    ]) {
      final reference =
          independentSineFirstCrossing(fixture.$1, forward, fixture.$2);
      expect(reference, closeTo(fixture.$3, 1e-10));
      await sample('warped-nearest-${fixture.$1}', fixture.$1, forward,
          depth: 2, phase: 0.4, status: 1, distance: reference);
    }
    await sample('finite-enclosure-miss', Vector3(3, -4, 0), Vector3(0, 1, 0),
        depth: 2, phase: 0.4, status: 0);
    await sample('bounded-budget-unresolved', Vector3(0, 0, 8), forward,
        depth: 6, strength: 1, budget: 64, status: 2);
    await sample('float-stagnation-not-a-miss', Vector3(0, 0, 100000), forward,
        depth: 2, phase: 0.4, status: 4);
  }, skip: !RuntimeModeService.forceGpuRender);

  testWidgets(
      'sine sphere renderer restores and exports requested frozen states',
      (tester) async {
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    SharedPreferences.setMockInitialValues({});
    binding.platformDispatcher.semanticsEnabledTestValue = false;
    tester.view.physicalSize = const Size(960, 720);
    tester.view.devicePixelRatio = 1;
    await binding.setSurfaceSize(const Size(960, 720));
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await binding.setSurfaceSize(null);
    });
    final store = await PresetStore.create();
    final accessibility = await AccessibilityService.create();
    final settings = await RendererSettingsService.create();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('linux_export_directory', evidence.path);
    await tester.pumpWidget(FlutterFractalsApp(
        presetStore: store,
        accessibilityService: accessibility,
        rendererSettingsService: settings,
        locale: const Locale('en')));
    await tester.pump(const Duration(seconds: 2));
    await enterCatalogSearch(tester, 'Recursive Sine-Warped Sphere');
    final card = catalogModuleCard('core.recursive_sine_sphere');
    expect(card, findsOneWidget);
    await tester.tap(card);
    await tester.pump(const Duration(seconds: 2));
    final controller =
        tester.element(find.byType(FractalRenderer)).read<FractalController>();
    final module = controller.module;
    expect(module.id, 'recursive_sine_sphere');
    final frames = <String, img.Image>{};
    final captures = <String, Object?>{};
    observations['captures'] = captures;
    final exports = <String, Object?>{};
    observations['exports'] = exports;

    Future<void> exportCurrent(String name, img.Image visible) async {
      final transparent = controller.transparentBackground;
      final renderer =
          tester.widget<FractalRenderer>(find.byType(FractalRenderer));
      var completed = false;
      final pending = const ExportService()
          .exportWithOptions(
            renderer.boundaryKey!,
            options: ExportOptions(
                format: ExportFormat.png,
                resolution: ExportResolution.custom,
                customWidth: visible.width,
                customHeight: visible.height,
                transparentBackground: transparent),
            screenWidth: visible.width.toDouble(),
            screenHeight: visible.height.toDouble(),
            fractalType: module.id,
            parameters: controller.params,
          )
          .whenComplete(() => completed = true);
      // Export waits for endOfFrame. Live test bindings still require explicit
      // pumps when reduced motion has stopped the application's ticker.
      for (var i = 0; i < 200 && !completed; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(completed, isTrue, reason: 'real export must finish within 10s');
      final result = await pending;
      final file = result.file!;
      final bytes = await file.readAsBytes();
      final decoded = img.decodePng(bytes)!;
      expect(decoded.width, visible.width);
      expect(decoded.height, visible.height);
      expect(_different(visible, decoded), isFalse,
          reason: 'decoded export must equal the actual frozen renderer');
      final metrics = _inspect(decoded);
      expect(metrics['transparentPixels'] as int,
          transparent ? greaterThan(100) : 0);
      exports[name] = {
        'path': file.path,
        'width': decoded.width,
        'height': decoded.height,
        'sha256': _sha256(file.path),
        'matchesVisibleRgba': true,
        ...metrics
      };
    }

    Future<img.Image> capture(String name,
        {bool framed = false, bool export = false}) async {
      await tester.pump(const Duration(milliseconds: 300));
      final renderer =
          tester.widget<FractalRenderer>(find.byType(FractalRenderer));
      final boundary = renderer.boundaryKey!.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final clock = Stopwatch()..start();
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
      image.dispose();
      clock.stop();
      final decoded = img.decodePng(bytes)!;
      final metrics = _inspect(decoded);
      await File('${evidence.path}/$name.png').writeAsBytes(bytes);
      captures[name] = {
        'module': module.id,
        'params': controller.params,
        'view': _view(controller),
        'transparent': controller.transparentBackground,
        'animationEnabled': renderer.animationEnabled,
        'renderTime': renderer.renderSnapshotSink?.snapshot?.time,
        'width': decoded.width,
        'height': decoded.height,
        'pngSha256': _sha256('${evidence.path}/$name.png'),
        'captureAndEncodeMs': clock.elapsedMicroseconds / 1000,
        ...metrics,
      };
      expect(metrics['contentPixels'] as int, greaterThan(100), reason: name);
      expect(metrics['colors'] as int, greaterThan(16), reason: name);
      if (framed)
        expect(metrics['edgeContentPixels'], 0, reason: '$name framing');
      frames[name] = decoded;
      if (export) await exportCurrent(name, decoded);
      return decoded;
    }

    // Ordinary sphere and the two shipping presets at their actual cameras.
    controller.updateParam('depth', 0);
    await capture('sphere-control', framed: true, export: true);
    await controller.applyPreset(module.defaultPreset);
    await capture('default', framed: true, export: true);
    await controller.applyPreset(module.builtInPresets.last);
    await capture('detail', framed: true, export: true);
    expect(_different(frames['sphere-control']!, frames['default']!), isTrue);
    expect(_different(frames['default']!, frames['detail']!), isTrue);
    // Same camera isolates depth from the fine preset's zoom change.
    final detailView = controller.view;
    controller.updateParam('depth', 3);
    await capture('detail-camera-depth3');
    controller.updateParam('depth', 5);
    await capture('detail-camera-depth5');
    expect(
        _different(
            frames['detail-camera-depth3']!, frames['detail-camera-depth5']!),
        isTrue);
    final coarseEnergy = _detailEnergy(frames['detail-camera-depth3']!);
    final fineEnergy = _detailEnergy(frames['detail-camera-depth5']!);
    observations['detailComparison'] = {
      'depth3MeanRgbLaplacian': coarseEnergy,
      'depth5MeanRgbLaplacian': fineEnergy,
      'sameCamera': true
    };
    expect(fineEnergy, greaterThan(coarseEnergy),
        reason: 'fixed-camera fine preset must contain more interior detail');
    controller.updateParam('depth', 6);
    controller.updateParam('strength', 1.0);
    controller.updateParam('steps', 512);
    await capture('maximum');

    // Full-frame production classifications explain background holes instead of
    // silently certifying budget exhaustion/stagnation as misses.
    final convergence = <String, Object?>{};
    observations['convergence'] = convergence;
    for (final entry in [
      ('default', module.defaultPreset.params, module.defaultPreset.view),
      ('detail', module.builtInPresets.last.params, detailView),
      ('maximum', controller.params, controller.view),
    ]) {
      final frame = frames[entry.$1]!;
      final clock = Stopwatch()..start();
      final rgba = await runSineKernelFrame(
          params: entry.$2,
          view: entry.$3,
          width: frame.width,
          height: frame.height);
      clock.stop();
      final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0};
      final silhouetteMismatches = <(int, int)>[];
      for (final pixel in frame) {
        final status = rgba[(pixel.y * frame.width + pixel.x) * 4];
        expect(counts.containsKey(status), isTrue);
        counts[status] = counts[status]! + 1;
        if (!_isBackground(pixel) != (status == 1 || status == 3)) {
          silhouetteMismatches.add((pixel.x, pixel.y));
        }
      }
      final diagnostic = img.Image.fromBytes(
          width: frame.width,
          height: frame.height,
          bytes: rgba.buffer,
          bytesOffset: rgba.offsetInBytes,
          numChannels: 4);
      await File('${evidence.path}/${entry.$1}-statuses.png')
          .writeAsBytes(img.encodePng(diagnostic));
      expect(silhouetteMismatches.length,
          entry.$1 == 'maximum' ? lessThanOrEqualTo(1) : 0,
          reason: 'only one qualified maximum-state float-boundary exception');
      final floatBoundarySamples = <Object>[];
      for (final pixel in silhouetteMismatches) {
        final frameStatus = rgba[(pixel.$2 * frame.width + pixel.$1) * 4];
        final foreground = !_isBackground(frame.getPixel(pixel.$1, pixel.$2));
        expect(frameStatus, 2); // diagnostic just exhausts its budget
        expect(foreground, isTrue); // production just accepts the hit
        final ray =
            _cameraRay(entry.$3, pixel.$1 + 0.5, pixel.$2 + 0.5, 960, 720);
        final actual = await runSineKernel(
            depth: (entry.$2['depth'] as num).toDouble(),
            strength: (entry.$2['strength'] as num).toDouble(),
            radius: (entry.$2['radius'] as num).toDouble(),
            phase: (entry.$2['phase'] as num).toDouble(),
            budget: (entry.$2['steps'] as num).toDouble(),
            origin: ray.$1,
            direction: ray.$2);
        final reference = independentSineFirstCrossing(ray.$1, ray.$2, null,
            depth: (entry.$2['depth'] as num).toInt(),
            strength: (entry.$2['strength'] as num).toDouble(),
            radius: (entry.$2['radius'] as num).toDouble(),
            phase: (entry.$2['phase'] as num).toDouble());
        // Separate compiled programs can differ at the final-budget float32
        // acceptance boundary. Accept no unexplained discrepancy: the ray must
        // still agree with the independent crossing at the declared tolerance.
        expect(actual.status, anyOf(1, 2));
        expect(actual.residual, lessThanOrEqualTo(5e-4));
        expect(actual.distance, closeTo(reference, 5e-4));
        floatBoundarySamples.add({
          'pixel': [pixel.$1, pixel.$2],
          'frameStatus': frameStatus,
          'visibleForeground': foreground,
          'status': actual.status,
          'distance': actual.distance,
          'residual': actual.residual,
          'referenceDistance': reference
        });
      }
      final centerOracle = <String, Object>{};
      if (entry.$1 != 'maximum') {
        const px = 480.5, py = 360.5;
        final ray = _cameraRay(entry.$3, px, py, 960, 720);
        final reference = independentSineFirstCrossing(ray.$1, ray.$2, null,
            depth: (entry.$2['depth'] as num).toInt(),
            strength: (entry.$2['strength'] as num).toDouble(),
            radius: (entry.$2['radius'] as num).toDouble(),
            phase: (entry.$2['phase'] as num).toDouble());
        final actual = await runSineKernel(
            depth: (entry.$2['depth'] as num).toDouble(),
            strength: (entry.$2['strength'] as num).toDouble(),
            radius: (entry.$2['radius'] as num).toDouble(),
            phase: (entry.$2['phase'] as num).toDouble(),
            budget: (entry.$2['steps'] as num).toDouble(),
            origin: ray.$1,
            direction: ray.$2);
        expect(actual.status, 1);
        expect(actual.distance, closeTo(reference, 5e-4));
        expect(actual.residual, lessThanOrEqualTo(5e-4));
        centerOracle.addAll({
          'pixel': [px, py],
          'referenceDistance': reference,
          'actualDistance': actual.distance,
          'residual': actual.residual
        });
      }
      convergence[entry.$1] = {
        'resolution': [frame.width, frame.height],
        'miss': counts[0],
        'hit': counts[1],
        'budgetExhausted': counts[2],
        'tangent': counts[3],
        'stagnation': counts[4],
        'silhouetteMismatches': silhouetteMismatches.length,
        'floatBoundarySamples': floatBoundarySamples,
        'centerOracle': centerOracle,
        'diagnosticDrawReadbackMs': clock.elapsedMicroseconds / 1000,
      };
    }

    await controller.applyPreset(module.defaultPreset);
    for (final edit in <String, Object>{
      'phase': 0.4,
      'depth': 2,
      'strength': 0.65,
      'radius': 1.2,
      'colorScheme': 2,
    }.entries) {
      controller.updateParam(edit.key, edit.value);
    }
    await controller.loadState(
        params: controller.params,
        view: controller.view.copyWith(
            pan: Vector2(0.15, -0.1),
            zoom: 1.05,
            rotation: Vector3(0.45, -0.2, 0.1)),
        transparentBackground: false);
    await capture('edited');
    expect(_different(frames['default']!, frames['edited']!), isTrue);
    final saved = FractalPreset(
        createdAt: DateTime.utc(2026),
        id: 'sine-qualification',
        moduleId: module.id,
        name: 'Sine qualification',
        params: controller.params,
        view: controller.view);
    await store.saveUserPreset(saved);
    await controller.applyPreset(module.defaultPreset);
    final reloadedStore = await PresetStore.create();
    final restored = (await reloadedStore.loadUserPresets(module.id)).single;
    await controller.applyPreset(restored);
    expect(controller.params, saved.params);
    expect(_view(controller), _presetView(saved));
    await capture('restored', export: true);
    expect(_different(frames['edited']!, frames['restored']!), isFalse);

    // The native IntegrationTest binding deliberately disables the renderer
    // ticker, even with FORCE_GPU_RENDER. Record that limit, not a false live
    // animation verdict; the browser journey exercises advancing time.
    observations['nativeAnimationTicker'] =
        'not exercised: RuntimeModeService.isAutomatedTest disables ticker';
    // Off and reduced-motion freeze the requested phase. Freeze does not claim
    // to preserve a prior tick (the renderer resets its time to zero).
    controller.updateParam('animate', true);
    await capture('animated-a');
    await tester.pump(const Duration(seconds: 2));
    await capture('animated-b');
    expect(_different(frames['animated-a']!, frames['animated-b']!), isFalse);
    controller.updateParam('animate', false);
    await capture('animation-off-a');
    await tester.pump(const Duration(seconds: 2));
    await capture('animation-off-b', export: true);
    expect(_different(frames['animation-off-a']!, frames['animation-off-b']!),
        isFalse);
    controller.updateParam('animate', true);
    await accessibility.setReducedMotion(true);
    await capture('reduced-motion-a');
    expect(
        tester
            .widget<FractalRenderer>(find.byType(FractalRenderer))
            .animationEnabled,
        isFalse);
    await tester.pump(const Duration(seconds: 2));
    await capture('reduced-motion-b');
    expect(_different(frames['reduced-motion-a']!, frames['reduced-motion-b']!),
        isFalse);

    for (final transparent in [false, true]) {
      controller.setTransparentBackground(transparent);
      await capture(transparent ? 'frozen-transparent' : 'frozen-opaque',
          export: true);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: !RuntimeModeService.forceGpuRender);
}

// Native qualification uses the host hash tool rather than a new dependency.
String _sha256(String path) {
  final result = Process.runSync('sha256sum', [path]);
  if (result.exitCode != 0) throw StateError('${result.stderr}');
  return (result.stdout as String).split(' ').first;
}

Map<String, Object> _view(FractalController c) => {
      'pan': c.view.pan.storage.toList(),
      'zoom': c.view.zoom,
      'rotation': c.view.rotation.storage.toList(),
    };
Map<String, Object> _presetView(FractalPreset p) => {
      'pan': p.view.pan.storage.toList(),
      'zoom': p.view.zoom,
      'rotation': p.view.rotation.storage.toList(),
    };

bool _different(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) return true;
  final aa = a.getBytes(order: img.ChannelOrder.rgba);
  final bb = b.getBytes(order: img.ChannelOrder.rgba);
  return !_equalBytes(aa, bb);
}

bool _equalBytes(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Interior high-frequency shading, excluding the silhouette/background boundary.
// This is a finite image detail metric, not a fractal-dimension or human verdict.
double _detailEnergy(img.Image image) {
  var sum = 0.0, count = 0;
  for (var y = 1; y < image.height - 1; y++) {
    for (var x = 1; x < image.width - 1; x++) {
      final p = image.getPixel(x, y);
      final neighbors = [
        image.getPixel(x - 1, y),
        image.getPixel(x + 1, y),
        image.getPixel(x, y - 1),
        image.getPixel(x, y + 1)
      ];
      if (_isBackground(p) || neighbors.any(_isBackground)) continue;
      sum += ((4 * p.r - neighbors.fold<num>(0, (s, n) => s + n.r)).abs() +
              (4 * p.g - neighbors.fold<num>(0, (s, n) => s + n.g)).abs() +
              (4 * p.b - neighbors.fold<num>(0, (s, n) => s + n.b)).abs()) /
          3;
      count++;
    }
  }
  return sum / count;
}

bool _isBackground(img.Pixel p) =>
    p.a == 0 ||
    ((p.r - 3).abs() <= 1 && (p.g - 5).abs() <= 1 && (p.b - 9).abs() <= 1);

Map<String, Object> _inspect(img.Image image) {
  var content = 0, edge = 0, transparent = 0;
  final colors = <int>{};
  for (final p in image) {
    if (p.a == 0) transparent++;
    if (!_isBackground(p)) {
      content++;
      if (p.x == 0 ||
          p.y == 0 ||
          p.x == image.width - 1 ||
          p.y == image.height - 1) edge++;
      colors.add((p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt());
    }
  }
  return {
    'contentPixels': content,
    'edgeContentPixels': edge,
    'transparentPixels': transparent,
    'colors': colors.length
  };
}

// GLSL mat3 constructors are column-major. Only camera coordinate conversion is
// repeated here; all intersections above execute the canonical production kernel.
(Vector3, Vector3) _cameraRay(
    FractalViewState view, double x, double y, double w, double h) {
  final a = view.rotation;
  final cx = math.cos(a.x), sx = math.sin(a.x);
  final cy = math.cos(a.y), sy = math.sin(a.y);
  final cz = math.cos(a.z), sz = math.sin(a.z);
  Vector3 rotate(Vector3 v) => Vector3(
        cy * cz * v.x + cy * sz * v.y - sy * v.z,
        (sx * sy * cz - cx * sz) * v.x +
            (sx * sy * sz + cx * cz) * v.y +
            sx * cy * v.z,
        (cx * sy * cz + sx * sz) * v.x +
            (cx * sy * sz - sx * cz) * v.y +
            cx * cy * v.z,
      );
  final pan = view.pan;
  return (
    Vector3(pan.x, pan.y, 0) + rotate(Vector3(0, 0, 3.2 / view.zoom)),
    rotate(Vector3((x - w / 2) * 2 / h, (y - h / 2) * 2 / h, -1.5)).normalized()
  );
}
