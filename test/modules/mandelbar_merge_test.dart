import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Mandelbar family (`z -> conj(z)^p + c`) now shares
/// `tricorn_gpu.frag`, which already parameterised `uPower`. These tests check
/// that the merged shader really computes that map at each entry's power, by
/// comparing its inside/outside classification against a CPU mirror.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mergedAsset =
      'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag';

  const entries = <String, double>{
    'mandelbar_cubic': 3.0,
    'mandelbar_power6': 6.0,
    'mandelbar_power7': 7.0,
    'mandelbar_power8': 8.0,
    'mandelbar_power9': 9.0,
  };

  group('mandelbar entries share the tricorn shader', () {
    test('every entry points at the merged shader with its own power', () {
      final registry = ModuleRegistry();
      entries.forEach((id, power) {
        final module = registry.byId(id);
        expect(module.shaderAsset, mergedAsset, reason: id);
        final param = module.parameters.firstWhere((p) => p.id == 'power');
        expect(param.defaultValue, power, reason: id);
      });
    });

    test('the shader keeps the anti-holomorphic derivative and power smoothing',
        () {
      final source = File(mergedAsset).readAsStringSync();
      expect(source,
          contains('der = power * cmul(zcPowMinusOne, vec2(der.x, -der.y))'));
      expect(source, contains('log2(max(power, 1.0001))'));
    });

    for (final entry in entries.entries) {
      final id = entry.key;
      final power = entry.value;

      test('$id renders z -> conj(z)^$power + c', () async {
        const size = 64;
        final module = ModuleRegistry().byId(id);
        final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
        final shader = program.fragmentShader();
        final recorder = ui.PictureRecorder();
        module.setUniforms(
          shader,
          FractalRenderState(
            transparentBackground: false,
            params: module.defaultPreset.params,
            view: module.defaultPreset.view,
          ),
          ui.Size(size.toDouble(), size.toDouble()),
          0,
        );
        Canvas(recorder).drawRect(
          Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
          Paint()..shader = shader,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(size, size);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;

        final view = module.defaultPreset.view;
        final params = module.defaultPreset.params;
        final iterations =
            (params['iterations'] as num?)?.toDouble() ?? 200.0;
        final bailout = (params['bailout'] as num?)?.toDouble() ?? 4.0;

        var inside = 0;
        var agree = 0;
        var total = 0;
        for (var y = 0; y < size; y++) {
          for (var x = 0; x < size; x++) {
            // Same pixel -> c mapping as the shader.
            final ux = (x + 0.5 - 0.5 * size) / size;
            final uy = (y + 0.5 - 0.5 * size) / size;
            final cx = ux / view.zoom + view.pan.x;
            final cy = uy / view.zoom + view.pan.y;

            final cpuInside = _escapes(cx, cy, power, iterations, bailout)
                ? false
                : true;
            final i = (y * size + x) * 4;
            final shaderInside = bytes.getUint8(i) == 0 &&
                bytes.getUint8(i + 1) == 0 &&
                bytes.getUint8(i + 2) == 0;

            if (cpuInside) inside++;
            if (cpuInside == shaderInside) agree++;
            total++;
          }
        }

        expect(inside, greaterThan(0), reason: '$id rendered an empty set');
        expect(inside, lessThan(total), reason: '$id filled the frame');
        expect(agree / total, greaterThan(0.97),
            reason: '$id matched the CPU mirror on only ${agree ~/ total * 100}% '
                'of pixels (inside=$inside)');

        picture.dispose();
        image.dispose();
        shader.dispose();
      });
    }
  });
}

/// True when the orbit of `c` leaves the bailout disc.
bool _escapes(double cx, double cy, double power, double iterations,
    double bailout) {
  final bailoutSq = bailout * bailout;
  var zx = 0.0;
  var zy = 0.0;
  final n = power.round();
  for (var i = 0; i < iterations; i++) {
    // conj(z)^p by repeated multiplication of conj(z).
    var ax = zx;
    var ay = -zy;
    var rx = 1.0;
    var ry = 0.0;
    for (var k = 0; k < n; k++) {
      final tx = rx * ax - ry * ay;
      final ty = rx * ay + ry * ax;
      rx = tx;
      ry = ty;
    }
    zx = rx + cx;
    zy = ry + cy;
    if (zx * zx + zy * zy > bailoutSq) return true;
  }
  return false;
}
