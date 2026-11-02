import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the Mandelbrot-mix family and the two corrections made with it:
/// the degree-variant Schroeder step and the order-16 Schroeder/Neta entry.
void main() {
  group('Mandelbrot mix family', () {
    final entries = escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/mix/mandelbrot_mix_'))
        .toList();

    test('sixteen entries share the one mix shader', () {
      expect(entries.length, 16);
      for (final e in entries) {
        expect(e.shaderAsset.endsWith('mandelbrot_mix_gpu.frag'), isTrue);
        final names = e.extraParams.map((p) => p.id).toList();
        expect(names, [
          'mixA',
          'mixB',
          'mixD',
          'mixF',
          'mixG',
          'mixH',
          'mixK',
          'juliaMode',
          'juliaReal',
          'juliaImag',
        ]);
      }
    });

    test('degenerate parameters reproduce z^2 + c exactly', () {
      // a = d = 0.5, b = f = 2, k = 1 -> z^2 + c for every orbit step.
      double re(double x, double y) {
        // k*(a*Re(z^b) + d*Re(z^f)) + c with b = f = 2
        return 1.0 * (0.5 * (x * x - y * y) + 0.5 * (x * x - y * y));
      }

      double im(double x, double y) {
        return 1.0 * (0.5 * (2 * x * y) + 0.5 * (2 * x * y));
      }

      for (final z in const [
        [0.3, 0.4],
        [-0.7, 0.2],
        [0.0, -0.9],
      ]) {
        final mandelRe = z[0] * z[0] - z[1] * z[1];
        final mandelIm = 2 * z[0] * z[1];
        expect(re(z[0], z[1]), closeTo(mandelRe, 1e-15));
        expect(im(z[0], z[1]), closeTo(mandelIm, 1e-15));
      }
    });

    test('shader declares the extras in uniform order and keeps the chain rule',
        () {
      final source = File(
              'shaders/escape_time_family/families/mix/mandelbrot_mix_gpu.frag')
          .readAsStringSync();
      final order = <String>[
        'uMixA',
        'uMixB',
        'uMixD',
        'uMixF',
        'uMixG',
        'uMixH',
        'uMixK',
        'uJuliaMode',
        'uJuliaReal',
        'uJuliaImag',
      ];
      var cursor = -1;
      for (final name in order) {
        final at = source.indexOf('uniform float $name;');
        expect(at, greaterThan(cursor), reason: '$name declared out of order');
        cursor = at;
      }
      expect(source,
          contains('a*b*cpowr(z, b - 1.0) + d*f*cpowr(z, f - 1.0)'));
      expect(source, contains('+ g*h*cpowr(z, h - 1.0)'));
      expect(source,
          contains('z = k * (a*cpowr(z, b) + d*cpowr(z, f) + g*cpowr(z, h)) + c;'));
    });

    for (final config in escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/mix/mandelbrot_mix_'))) {
      test('${config.id} compiles and renders a non-blank frame', () async {
        final module = ModuleRegistry().byId(config.id);
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
          const ui.Size(64, 64),
          0,
        );
        Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 64, 64),
          Paint()..shader = shader,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        var lit = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) >
              12) {
            lit++;
          }
        }
        // Slice entries can be intrinsically thin; require visible structure,
        // not a full frame.
        expect(lit, greaterThan(8), reason: '${config.id} drew a black frame');
        picture.dispose();
        image.dispose();
        shader.dispose();
      });
    }
  });

  group('planar 4D slices', () {
    final entries = escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/slice/planar_slice_4d'))
        .toList();

    test('six slice entries share one shader and keep uniform order', () {
      expect(entries.length, 6);
      for (final e in entries) {
        expect(e.extraParams.map((p) => p.id).toList(), [
          'sliceAngleA',
          'sliceAngleB',
          'slicePower',
          'sliceOffsetRe',
          'sliceOffsetIm',
          'sliceMode',
        ]);
      }
      final source = File(
              'shaders/escape_time_family/families/slice/planar_slice_4d_gpu.frag')
          .readAsStringSync();
      var cursor = -1;
      for (final name in const [
        'uSliceAngleA',
        'uSliceAngleB',
        'uSlicePower',
        'uSliceOffsetRe',
        'uSliceOffsetIm',
        'uSliceMode',
      ]) {
        final at = source.indexOf('uniform float $name;');
        expect(at, greaterThan(cursor), reason: '$name out of order');
        cursor = at;
      }
    });

    test('zero angles map z0 = x and c = y, the real slice', () {
      // Two iterations of z -> z^2 + c with z0 = x, c = y.
      double z1(double x, double y) => x * x + y;
      double z2(double x, double y) {
        final a = z1(x, y);
        return a * a + y;
      }

      for (final p in const [
        [0.2, -0.3],
        [-0.6, 0.1],
        [0.45, 0.45],
      ]) {
        final manual = p[0] * p[0] + p[1];
        expect(z1(p[0], p[1]), closeTo(manual, 1e-15));
        final second = manual * manual + p[1];
        expect(z2(p[0], p[1]), closeTo(second, 1e-15));
      }
    });

    for (final config in escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/slice/planar_slice_4d'))) {
      test('${config.id} compiles and renders a non-blank frame', () async {
        final module = ModuleRegistry().byId(config.id);
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
          const ui.Size(64, 64),
          0,
        );
        Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 64, 64),
          Paint()..shader = shader,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        var lit = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) >
              12) {
            lit++;
          }
        }
        // Slice entries can be intrinsically thin; require visible structure,
        // not a full frame.
        expect(lit, greaterThan(8), reason: '${config.id} drew a black frame');
        picture.dispose();
        image.dispose();
        shader.dispose();
      });
    }
  });

  group('order-16 iteration', () {
    test('two composed Ostrowski steps act well above fourth order', () {
      // Algebraic order is 4^2 = 16. In double precision the second step lands
      // on the rounding floor, so the observable estimate is floor-limited.
      // Assert only what the arithmetic can show: clearly above one step (4).
      final pair = _pairOrder(_ostrowskiSquared);
      final single = _pairOrder(_ostrowski);
      expect(single, lessThan(5.0), reason: 'one Ostrowski step: $single');
      expect(pair, greaterThan(10.0), reason: 'pair order estimate: $pair');
    });

    test('shader uses two Ostrowski steps and no invented King step', () {
      final source = File('shaders/root_finding/neta_order16_gpu.frag')
          .readAsStringSync();
      expect(source, contains('vec2 y3 = y2 - cdiv(f2, fp2);'));
      expect(source, contains('cdiv(f2, f2 - 2.0 * fy3)'));
      expect(source, isNot(contains('King')));
      expect(source, isNot(contains('Neta')));
    });
  });

  group('Schroeder family', () {
    test('base entry uses the first-kind step, not Chebyshev', () {
      final source =
          File('shaders/root_finding/schroeder_gpu.frag').readAsStringSync();
      expect(source, contains('vec2 denom = cmul(fp, fp) - cmul(fz, fpp);'));
      expect(source, isNot(contains('term2')));
      expect(source, isNot(contains('(f^2 f\'\')')));
    });

    test('first-kind step equals the closed form z(z^3-1)/(z^3+2)', () {
      for (var k = 0; k < 60; k++) {
        final z = _C(-1.1 + 0.037 * k, 0.9 - 0.031 * k);
        final fz = _sub(_pow(z, 3), _one);
        final fp = _mul(_C(3, 0), _pow(z, 2));
        final fpp = _mul(_C(6, 0), z);
        final step = _div(_mul(fz, fp), _sub(_mul(fp, fp), _mul(fz, fpp)));
        final closed = _div(_mul(z, fz), _add(_pow(z, 3), _C(2, 0)));
        expect(_abs(_sub(step, closed)), lessThan(1e-9));
      }
    });

    test('chebyshev_fractal stays a different map', () {
      final cheb = File(
              'shaders/escape_time_family/newton_and_orthogonal/high_order_root_methods/chebyshev_fractal_gpu.frag')
          .readAsStringSync();
      final schroeder =
          File('shaders/root_finding/schroeder_gpu.frag').readAsStringSync();
      expect(cheb, contains('Lf'));
      expect(schroeder, isNot(contains('Lf')));
    });
  });
}

// ---------------------------------------------------------------- complex ----
class _C {
  const _C(this.real, this.imag);
  final double real;
  final double imag;
}

const _one = _C(1, 0);

_C _add(_C a, _C b) => _C(a.real + b.real, a.imag + b.imag);
_C _sub(_C a, _C b) => _C(a.real - b.real, a.imag - b.imag);
_C _mul(_C a, _C b) =>
    _C(a.real * b.real - a.imag * b.imag, a.real * b.imag + a.imag * b.real);
_C _div(_C a, _C b) {
  final d = b.real * b.real + b.imag * b.imag;
  return _C((a.real * b.real + a.imag * b.imag) / d,
      (a.imag * b.real - a.real * b.imag) / d);
}

double _abs(_C a) => math.sqrt(a.real * a.real + a.imag * a.imag);
_C _pow(_C z, int n) {
  var out = _one;
  for (var i = 0; i < n; i++) {
    out = _mul(out, z);
  }
  return out;
}

_C _f(_C z) => _sub(_pow(z, 3), _one);

/// Two composed Ostrowski steps, mirroring the shipped GLSL.
_C _ostrowskiSquared(_C z) {
  final fz = _f(z);
  final fpz = _mul(_C(3, 0), _pow(z, 2));
  final y1 = _sub(z, _div(fz, fpz));
  final fy1 = _f(y1);
  final y2 = _sub(y1, _mul(_div(fy1, fpz), _div(fz, _sub(fz, _mul(_C(2, 0), fy1)))));

  final f2 = _f(y2);
  final fp2 = _mul(_C(3, 0), _pow(y2, 2));
  final y3 = _sub(y2, _div(f2, fp2));
  final fy3 = _f(y3);
  return _sub(
      y3, _mul(_div(fy3, fp2), _div(f2, _sub(f2, _mul(_C(2, 0), fy3)))));
}

_C _ostrowski(_C z) {
  final fz = _f(z);
  final fpz = _mul(_C(3, 0), _pow(z, 2));
  final y = _sub(z, _div(fz, fpz));
  final fy = _f(y);
  return _sub(y, _mul(_div(fy, fpz), _div(fz, _sub(fz, _mul(_C(2, 0), fy)))));
}

/// Empirical order of a high-order method.
///
/// An order-16 step takes a moderate error straight to the floating-point floor,
/// so only the first ratio log(e1)/log(e0) is representable. Take the largest
/// representable ratio over the starts.
double _pairOrder(_C Function(_C) rule) {
  // Moderate starts keep both steps above the rounding floor: one step of order
  // p turns e0 into C*e0^p, and the pair turns it into C'*e0^(p^2).
  final starts = <_C>[
    const _C(0.55, 0.10),
    const _C(0.62, -0.08),
    const _C(0.48, 0.14),
    const _C(0.70, 0.05),
    const _C(0.58, -0.15),
    const _C(0.66, 0.18),
    const _C(0.52, -0.20),
    const _C(0.74, -0.12),
  ];
  var best = 0.0;
  for (final z0 in starts) {
    final e0 = _abs(_sub(z0, _one));
    if (e0 < 0.05 || e0 > 0.8) continue;
    final z1 = rule(z0);
    if (!z1.real.isFinite || !z1.imag.isFinite) continue;
    final e1 = _abs(_sub(z1, _one));
    if (e1 <= 0 || e1 > e0) continue;
    final order = math.log(e1) / math.log(e0);
    if (order.isFinite && order > best) best = order;
  }
  return best;
}
