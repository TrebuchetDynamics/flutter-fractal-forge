import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Formula pins for every repaired root-finding shader, plus the order-16
/// Ostrowski-squared entry and the degree-variant Schroeder family.
///
/// The defects and the measurements that found them live in
/// `research/fractal-correctness-audit/`. These tests keep the shipped shader
/// text and an independent CPU evaluation of the same recurrence in agreement,
/// so a silent coefficient edit fails here instead of shipping.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('repaired shaders still compile and render', () {
    for (final id in [
      'jarratt',
      'schroeder',
      'schroeder_z5',
      'schroeder_z6',
      'ostrowski_squared_16',
    ]) {
      test('$id compiles and draws a non-blank frame', () async {
        // The software rasterizer occasionally drops a frame when many test
        // files compile shaders at once, so a blank first attempt is retried
        // once. A genuinely broken shader stays blank on both attempts.
        var lit = await _litPixels(id);
        if (lit == 0) lit = await _litPixels(id);
        expect(lit, greaterThan(48), reason: '$id rendered a black frame');
      });
    }
  });

  group('Jarratt', () {
    const asset = 'shaders/root_finding/jarratt_gpu.frag';

    test('uses the published fourth-order weights', () {
      final source = File(asset).readAsStringSync();
      expect(source, contains('vec2 num = 3.0 * fpy + fpz;'));
      expect(source, contains('vec2 den = 6.0 * fpy - 2.0 * fpz;'));
      // The pre-repair weights measured second order. Keep them out.
      expect(source, isNot(contains('3.0 * fpy - fpz')));
      expect(source, isNot(contains('2.0 * (3.0 * fpy - 2.0 * fpz)')));
    });

    test('converges with fourth order on z^3 - 1', () {
      final order = _medianOrder(_jarratt);
      expect(order, greaterThan(3.5),
          reason: 'measured order $order; Jarratt is a fourth-order method');
    });

    test('the pre-repair weights were second order (regression witness)', () {
      final order = _medianOrder(_jarrattLegacyWeights);
      expect(order, lessThan(2.5),
          reason: 'measured order $order for the removed coefficient set');
    });
  });

  group('Schroeder degree family', () {
    test('z5 and z6 use the first-kind step shared with z3 and z4', () {
      for (final n in [3, 4, 5, 6]) {
        final source =
            File('shaders/root_finding/schroeder_z${n}_gpu.frag').readAsStringSync();
        expect(source, contains('z$n + vec2(${n - 1}.0, 0.0)'),
            reason: 'z$n must use the z^n + (n-1) denominator');
      }
      expect(File('shaders/root_finding/schroeder_z5_gpu.frag').readAsStringSync(),
          isNot(contains('3.0*z5 + vec2(2.0, 0.0)')));
      expect(File('shaders/root_finding/schroeder_z6_gpu.frag').readAsStringSync(),
          isNot(contains('7.0*z6 + vec2(5.0, 0.0)')));
      expect(File('shaders/root_finding/schroeder_z6_gpu.frag').readAsStringSync(),
          isNot(contains('2.0 * cmul(z, z6m1)')));
    });

    test('the closed-form step equals the first-kind Schroeder step', () {
      for (final n in [3, 4, 5, 6]) {
        var worst = 0.0;
        for (var k = 0; k < 200; k++) {
          final z = _C(0.15 + 0.0137 * k, -1.1 + 0.0111 * k);
          if (_abs(_f(z, n)) < 1e-9) continue;
          final closed = _div(_mul(z, _sub(_pow(z, n), _one)),
              _add(_pow(z, n), _C(n - 1, 0)));
          worst = math.max(worst, _abs(_sub(closed, _firstKindStep(z, n))));
        }
        expect(worst, lessThan(1e-9), reason: 'n=$n');
      }
    });

    test('the removed Halley step differs from the shipped step', () {
      var worst = 0.0;
      for (final n in [5, 6]) {
        for (var k = 0; k < 200; k++) {
          final z = _C(0.21 + 0.0101 * k, 0.37 - 0.0093 * k);
          if (_abs(_f(z, n)) < 1e-9) continue;
          final shipped = _div(_mul(z, _sub(_pow(z, n), _one)),
              _add(_pow(z, n), _C(n - 1, 0)));
          worst = math.max(worst, _abs(_sub(shipped, _halleyStep(z, n))));
        }
      }
      expect(worst, greaterThan(1e-3),
          reason: 'the family must not silently fall back to Halley');
    });
  });

  group('Ostrowski squared order-16', () {
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

    test('module id renamed but the shader asset path is unchanged', () {
      final registry = ModuleRegistry();
      expect(() => registry.byId('ostrowski_squared_16'), returnsNormally);
      expect(() => registry.byId('neta_order16'), throwsA(anything),
          reason: 'the registry must not keep the retired id');
      expect(registry.byId('ostrowski_squared_16').shaderAsset,
          'shaders/root_finding/neta_order16_gpu.frag',
          reason: 'asset paths are hashed into release artifacts');
    });
  });

  group('Schroeder base entry', () {
    test('uses the first-kind step, not Chebyshev', () {
      final source =
          File('shaders/root_finding/schroeder_gpu.frag').readAsStringSync();
      expect(source, contains('vec2 denom = cmul(fp, fp) - cmul(fz, fpp);'));
      expect(source, isNot(contains('term2')));
      expect(source, isNot(contains("(f^2 f'')")));
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

  group('Klein j invariant', () {
    const asset = 'shaders/number_theory/klein_j_invariant_gpu.frag';

    test('keeps the arithmetic normalisation (j = E4^3 / Delta)', () {
      final source = File(asset).readAsStringSync();
      expect(source, contains('cdiv(cmul(cmul(e4,e4),e4),delta)'));
      // Delta already contains the 1/1728 of (E4^3 - E6^2). Multiplying again
      // yields 1728^2 at tau = i; the identity test below catches that.
      expect(source, isNot(contains('1728.0*cdiv')));
    });

    test('j(i) = 1728 for the shipped truncated series', () {
      final j = _kleinJ(_C(0, 1));
      expect(j.imag.abs(), lessThan(1e-9));
      expect((j.real - 1728.0).abs(), lessThan(1e-6),
          reason: 'j(i) measured ${j.real}');
    });
  });
}


Future<int> _litPixels(String moduleId) async {
  final module = ModuleRegistry().byId(moduleId);
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  module.setUniforms(
    shader,
    FractalRenderState(
      transparentBackground: false,
      params: module.defaultPreset.params,
      view: module.defaultPreset.view,
    ),
    const ui.Size(48, 48),
    0,
  );
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 48, 48),
    Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(48, 48);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  var lit = 0;
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) >
        12) {
      lit++;
    }
  }
  picture.dispose();
  image.dispose();
  shader.dispose();
  return lit;
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

_C _exp(_C z) {
  final e = math.exp(z.real);
  return _C(e * math.cos(z.imag), e * math.sin(z.imag));
}

// ------------------------------------------------------------- recurrences ---
_C _f(_C z, int n) => _sub(_pow(z, n), _one);

_C _firstKindStep(_C z, int n) {
  final fz = _f(z, n);
  final fp = _C(n.toDouble(), 0);
  final fpz = _mul(fp, _pow(z, n - 1));
  final fppz = _mul(_C((n * (n - 1)).toDouble(), 0), _pow(z, n - 2));
  return _div(_mul(fz, fpz),
      _sub(_mul(fpz, fpz), _mul(fz, fppz)));
}

_C _halleyStep(_C z, int n) {
  final fz = _f(z, n);
  final fpz = _mul(_C(n.toDouble(), 0), _pow(z, n - 1));
  final fppz = _mul(_C((n * (n - 1)).toDouble(), 0), _pow(z, n - 2));
  return _div(_mul(_C(2, 0), _mul(fz, fpz)),
      _sub(_mul(_C(2, 0), _mul(fpz, fpz)), _mul(fz, fppz)));
}

_C _jarratt(_C z) {
  final fz = _sub(_pow(z, 3), _one);
  final fpz = _mul(_C(3, 0), _mul(z, z));
  final y = _sub(z, _mul(_C(2 / 3, 0), _div(fz, fpz)));
  final fpy = _mul(_C(3, 0), _mul(y, y));
  final num = _add(_mul(_C(3, 0), fpy), fpz);
  final den = _sub(_mul(_C(6, 0), fpy), _mul(_C(2, 0), fpz));
  return _sub(z, _mul(_div(fz, fpz), _div(num, den)));
}

_C _jarrattLegacyWeights(_C z) {
  final fz = _sub(_pow(z, 3), _one);
  final fpz = _mul(_C(3, 0), _mul(z, z));
  final y = _sub(z, _mul(_C(2 / 3, 0), _div(fz, fpz)));
  final fpy = _mul(_C(3, 0), _mul(y, y));
  final num = _sub(_mul(_C(3, 0), fpy), fpz);
  final den = _mul(_C(2, 0), _sub(_mul(_C(3, 0), fpy), _mul(_C(2, 0), fpz)));
  return _sub(z, _mul(_div(fz, fpz), _div(num, den)));
}

_C _f3(_C z) => _sub(_pow(z, 3), _one);

/// Two composed Ostrowski steps, mirroring the shipped GLSL.
_C _ostrowskiSquared(_C z) {
  final fz = _f3(z);
  final fpz = _mul(_C(3, 0), _pow(z, 2));
  final y1 = _sub(z, _div(fz, fpz));
  final fy1 = _f3(y1);
  final y2 = _sub(y1,
      _mul(_div(fy1, fpz), _div(fz, _sub(fz, _mul(_C(2, 0), fy1)))));

  final f2 = _f3(y2);
  final fp2 = _mul(_C(3, 0), _pow(y2, 2));
  final y3 = _sub(y2, _div(f2, fp2));
  final fy3 = _f3(y3);
  return _sub(
      y3, _mul(_div(fy3, fp2), _div(f2, _sub(f2, _mul(_C(2, 0), fy3)))));
}

_C _ostrowski(_C z) {
  final fz = _f3(z);
  final fpz = _mul(_C(3, 0), _pow(z, 2));
  final y = _sub(z, _div(fz, fpz));
  final fy = _f3(y);
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

/// Median empirical order log(e_{n+1})/log(e_n) over convergent starts.
double _medianOrder(_C Function(_C) rule) {
  const roots = [
    _C(1, 0),
    _C(-0.5, 0.8660254037844386),
    _C(-0.5, -0.8660254037844386),
  ];
  final orders = <double>[];
  for (var k = 0; k < 240; k++) {
    final radius = 0.25 + 0.55 * (k % 40) / 40.0;
    final angle = 0.37 * k;
    var z = _C(radius * math.cos(angle), radius * math.sin(angle));
    var previous = _abs(_sub(z, roots.first));
    var converged = false;
    double? lastOrder;
    for (var i = 0; i < 14; i++) {
      z = rule(z);
      if (!z.real.isFinite || !z.imag.isFinite) break;
      final root = roots.reduce(
          (a, b) => _abs(_sub(z, a)) < _abs(_sub(z, b)) ? a : b);
      final error = _abs(_sub(z, root));
      // Order estimate while both errors are representable; stop at the
      // floating-point floor instead of taking log(0).
      if (previous > 1e-12 && error > 1e-14) {
        lastOrder = math.log(error) / math.log(previous);
      }
      if (error < 1e-12) {
        converged = true;
        break;
      }
      previous = error;
    }
    if (converged && lastOrder != null) orders.add(lastOrder);
  }
  if (orders.isEmpty) return 0;
  orders.sort();
  return orders[orders.length ~/ 2];
}

/// Truncated q-series used by the Klein shader: j = E4^3 / Delta.
_C _kleinJ(_C tau) {
  const terms = 24;
  // q = exp(2*pi*i*tau)
  final q = _exp(_C(-2 * math.pi * tau.imag, 2 * math.pi * tau.real));
  double sigma3(int n) {
    var s = 0.0;
    for (var d = 1; d <= n; d++) {
      if (n % d == 0) s += (d * d * d).toDouble();
    }
    return s;
  }

  var e4 = _one;
  var delta = q;
  for (var n = 1; n <= terms; n++) {
    e4 = _add(e4, _mul(_C(240.0 * sigma3(n), 0), _pow(q, n)));
    delta = _mul(delta, _pow(_sub(_one, _pow(q, n)), 24));
  }
  return _div(_mul(_mul(e4, e4), e4), delta);
}
