import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Formula pins for the repaired root-finding shaders.
///
/// The defects and the measurements that found them live in
/// `research/fractal-correctness-audit/`. These tests keep the shipped shader
/// text and an independent CPU evaluation of the same recurrence in agreement,
/// so a silent coefficient edit fails here instead of shipping.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('repared shaders still compile and render', () {
    for (final id in ['jarratt', 'schroeder_z5', 'schroeder_z6']) {
      test('$id compiles and draws a non-blank frame', () async {
        final module = ModuleRegistry().byId(id);
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
          if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) > 12) {
            lit++;
          }
        }
        expect(lit, greaterThan(48), reason: '$id rendered a black frame');
        picture.dispose();
        image.dispose();
        shader.dispose();
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
          final closed = _scalarDiv(_mul(z, _sub(_pow(z, n), _one)),
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
          final shipped = _scalarDiv(_mul(z, _sub(_pow(z, n), _one)),
              _add(_pow(z, n), _C(n - 1, 0)));
          worst = math.max(worst, _abs(_sub(shipped, _halleyStep(z, n))));
        }
      }
      expect(worst, greaterThan(1e-3),
          reason: 'the family must not silently fall back to Halley');
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

_C _scalarDiv(_C a, _C b) => _div(a, b);
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
