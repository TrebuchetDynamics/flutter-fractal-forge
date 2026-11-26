import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

import '../helpers/fractal_controller_widget_harness.dart';
import 'shader_cache_recovery_gpu.dart' show pumpUntil;

const _size = 512;
const _centerX = -0.7436;
const _centerY = 0.1318;

int _countColumns(Uint8List rgba) {
  final signatures = <String>{};
  final column = Uint8List(_size * 4);
  for (var x = 0; x < _size; x++) {
    for (var y = 0; y < _size; y++) {
      final i = (y * _size + x) * 4;
      column.setRange(y * 4, y * 4 + 4, rgba, i);
    }
    signatures.add(base64Encode(column));
  }
  return signatures.length;
}

// Independent binary64 render with the original float path's palette 0,
// bailout radius 4, opaque black interior and time zero. Sample pixel centers
// and quantize to RGBA8: identical shaded columns are not always precision loss.
int _referenceColumns(double zoom, int target) {
  final rgba = Uint8List(_size * _size * 4);
  for (var y = 0; y < _size; y++) {
    final cy = _centerY + (y + 0.5 - _size / 2) / (_size * zoom);
    for (var x = 0; x < _size; x++) {
      final cx = _centerX + (x + 0.5 - _size / 2) / (_size * zoom);
      var zx = 0.0, zy = 0.0, mag2 = 0.0;
      var it = 0;
      for (; it < target; it++) {
        final nextX = zx * zx - zy * zy + cx;
        zy = 2 * zx * zy + cy;
        zx = nextX;
        mag2 = zx * zx + zy * zy;
        if (mag2 > 16) break;
      }
      final i = (y * _size + x) * 4;
      rgba[i + 3] = 255;
      if (it == target) continue;
      final smooth = it - math.log(math.log(mag2) / math.ln2) / math.ln2 + 4;
      final t = (smooth / 64) % 1;
      const offsets = [0.0, 0.4, 0.7];
      for (var channel = 0; channel < 3; channel++) {
        final linear = 0.5 + 0.5 * math.cos(6.28318 * (t + offsets[channel]));
        final srgb = linear < 0.0031308
            ? 12.92 * linear
            : 1.055 * math.pow(linear, 1 / 2.4) - 0.055;
        rgba[i + channel] = (255 * srgb).round();
      }
    }
  }
  return _countColumns(rgba);
}

Future<({Uint8List rgba, String asset, Object? iterations})> _render(
  WidgetTester tester, {
  required Vector2 center,
  required double zoom,
  int scheme = 0,
  int size = _size,
}) async {
  expect(const bool.fromEnvironment('FORCE_GPU_RENDER'), isTrue,
      reason: 'Run this dedicated file with FORCE_GPU_RENDER=true');
  SharedPreferences.setMockInitialValues({});
  final palettes = await PaletteService.create();
  final harness = FractalControllerWidgetHarness();
  final controller = harness.controller;
  final key = GlobalKey();
  final sink = FractalRenderSnapshotSink();
  try {
    controller.selectModule(harness.registry.byId('mandelbrot'),
        animate: false);
    controller.updateParam('colorScheme', scheme);
    controller.updateParam('iterations', 120);
    controller.updateParam('bailout', 4.0);
    controller.updateView(controller.view.copyWith(pan: center, zoom: zoom));
    await tester.pumpWidget(harness.wrapScaffold(Center(
      child: SizedBox.square(
        dimension: size.toDouble(),
        child: FractalRenderer(
          animationEnabled: false,
          showRendererIndicator: false,
          boundaryKey: key,
          renderSnapshotSink: sink,
        ),
      ),
    )));
    await pumpUntil(
        tester, () => sink.snapshot != null, 'a loaded shader frame');
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final rgba = await tester.runAsync(() async {
      final image = await boundary.toImage();
      try {
        expect(image.width, size);
        expect(image.height, size);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        return bytes.buffer
            .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      } finally {
        image.dispose();
      }
    });
    expect(tester.takeException(), isNull);
    final snapshot = sink.snapshot!;
    return (
      rgba: rgba!,
      asset: snapshot.module.shaderAsset,
      iterations: snapshot.state.params['iterations'],
    );
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    harness.dispose();
    palettes.dispose();
  }
}

const _df2Asset = 'shaders/legacy/precision/mandelbrot_df2.frag';
final _desktop = TargetPlatformVariant({TargetPlatform.linux});

// Run explicitly, like shader_cache_recovery_gpu.dart: the ordinary widget
// suite replaces the shader surface with a placeholder.
// flutter test --no-pub --dart-define=FORCE_GPU_RENDER=true test/fractal/mandelbrot_precision_gpu.dart
void main() {
  for (final (zoom, target, minimum) in [(1e5, 330, 461), (1e6, 372, 369)]) {
    testWidgets('Mandelbrot keeps distinct viewer columns at zoom $zoom',
        (tester) async {
      final frame = await _render(tester,
          center: Vector2(_centerX, _centerY), zoom: zoom);
      expect(frame.iterations, target);
      final count = _countColumns(frame.rgba);
      final reference = _referenceColumns(zoom, target);
      final actual =
          '$zoom using ${frame.asset}: $count/$reference distinct columns';
      expect(count,
          greaterThanOrEqualTo(math.max(minimum, (reference * 0.9).ceil())),
          reason: actual);
      debugPrint(actual);
      expect(frame.asset, _df2Asset);
    }, variant: _desktop);
  }

  for (final (label, x, y, scheme) in [
    ('black interior', 0.0, 0.0, 0),
    ('relief palette', 0.3, 0.7, 50),
  ]) {
    testWidgets('Mandelbrot keeps $label when switching to DF2',
        (tester) async {
      const size = 32;
      final center = Vector2(x, y);
      final standard = await _render(tester,
          center: center, zoom: 9999, scheme: scheme, size: size);
      final extended = await _render(tester,
          center: center, zoom: 1e4, scheme: scheme, size: size);
      expect(
          standard.asset, 'shaders/legacy/escape_time/mandel_step_smooth.frag');
      expect(extended.asset, _df2Asset);
      const i = (size * (size ~/ 2) + size ~/ 2) * 4;
      final standardPixel = standard.rgba.sublist(i, i + 4);
      expect(standardPixel[3], 255);
      if (scheme == 0) {
        expect(standardPixel, [0, 0, 0, 255]);
      } else {
        expect(standardPixel.take(3).any((channel) => channel > 0), isTrue);
      }
      expect(extended.rgba.sublist(i, i + 4),
          orderedEquals(standardPixel.map((channel) => closeTo(channel, 1))),
          reason: '$label should not change at the precision switch');
    }, variant: _desktop);
  }
}
