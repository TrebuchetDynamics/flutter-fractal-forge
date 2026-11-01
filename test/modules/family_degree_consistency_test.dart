import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Family-level invariants for the escape-time power families and the 3D
/// slice-brot derivatives.
///
/// `research/fractal-correctness-audit/report.md` records the audit that
/// motivates these checks. A power-map shader must use the same degree in three
/// places: the map, the derivative constant (`der = K *`), and the smooth
/// colouring normalisation (`log2(K)`). A mismatch is a wrong fractal, not a
/// cosmetic difference.
void main() {
  final powerEntries = escapeTimeCatalog.where((config) {
    final name = config.shaderAsset.split('/').last;
    return RegExp(r'_power\d+(_julia)?_gpu\.frag$').hasMatch(name) ||
        RegExp(r'multibrot_?\d+_gpu\.frag$').hasMatch(name);
  }).toList();

  test('power families are present in the catalog', () {
    expect(powerEntries.length, greaterThan(40),
        reason: 'power families should not silently disappear');
  });

  test('every power shader uses one degree in map, derivative and colouring',
      () {
    final problems = <String>[];
    for (final config in powerEntries) {
      final file = File(config.shaderAsset);
      if (!file.existsSync()) {
        problems.add('${config.id}: missing ${config.shaderAsset}');
        continue;
      }
      final source = file.readAsStringSync();
      final expected = _expectedDegree(config.id, config.name);
      if (expected == null) {
        problems.add('${config.id}: cannot derive degree from id or name');
        continue;
      }
      final ders = _matches(source, RegExp(r'der\s*=\s*([0-9.]+)\s*\*'))
          .map(double.parse)
          .toSet();
      final smooth = _matches(source, RegExp(r'log2\(\s*([0-9.]+)\s*\)'))
          .map(double.parse)
          .toSet();

      if (ders.isNotEmpty && (ders.length != 1 || ders.first != expected)) {
        problems.add('${config.id}: derivative degree $ders, expected $expected');
      }
      if (smooth.isNotEmpty && (smooth.length != 1 || smooth.first != expected)) {
        problems.add('${config.id}: colouring log2($smooth), expected $expected');
      }
      if (ders.isNotEmpty &&
          smooth.isNotEmpty &&
          !(ders.length == smooth.length &&
              ders.every((value) => smooth.contains(value)))) {
        problems.add('${config.id}: derivative $ders != colouring $smooth');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('3D slice-brot distance estimate', () {
    // sqrt((d0^2 + ... + dk^2)/k) is an intersection-consistent bound: it never
    // exceeds max(d_i), so the marcher cannot skip the surface. Verified here
    // so a future edit to min() or max() is a conscious decision.
    test('RMS combination never exceeds the intersection bound', () {
      final worst = _worstExcessOverIntersection();
      expect(worst, lessThanOrEqualTo(1e-9),
          reason: 'shipped slice combination exceeded max(d_i) by $worst');
    });

    test('the five slice-brot shaders still combine with the RMS form', () {
      for (final name in const [
        'tetrabrot_3d',
        'arrowheadbrot_3d',
        'mousebrot_3d',
        'turtlebrot_3d',
        'hourglassbrot_3d',
      ]) {
        final source = File(
                'shaders/3d_and_hypercomplex/raymarched_volumes/${name}_gpu.frag')
            .readAsStringSync();
        expect(source, anyOf(contains('sqrt(0.5'), contains('sqrt(0.25')),
            reason: '$name no longer uses the documented combination');
        expect(source, contains('complexMandelbrotDistance'));
      }
    });
  });

  group('perpendicular and celtic folds', () {
    test('perpendicular maps fold the real axis of z^2 only', () {
      final source = File(
              'shaders/escape_time_family/families/perpendicular/perpendicular_gpu.frag')
          .readAsStringSync();
      expect(source, contains('vec2(abs(x2) + c.x, y2 + c.y)'));
    });

    test('perpendicular burning ship folds one axis before squaring', () {
      final source = File(
              'shaders/escape_time_family/families/perpendicular/perpendicular_burning_ship_gpu.frag')
          .readAsStringSync();
      expect(source, contains('vec2 w = vec2(abs(z.x), z.y)'));
      expect(source, isNot(contains('abs(z.y)')));
    });
  });
}

double? _expectedDegree(String id, String name) {
  final named = RegExp(r'd\s*=\s*(\d+(?:\.\d+)?)').firstMatch(name);
  if (named != null) return double.parse(named.group(1)!);
  final fromId = RegExp(r'_power(\d+)|multibrot_?(\d+)').firstMatch(id);
  if (fromId == null) return null;
  return double.parse(fromId.group(1) ?? fromId.group(2)!);
}

Iterable<String> _matches(String source, RegExp pattern) =>
    pattern.allMatches(source).map((m) => m.group(1)!);

/// Worst amount by which the shipped RMS combination exceeds max(d_i).
double _worstExcessOverIntersection() {
  double de(double x, double y) {
    var zx = 0.0, zy = 0.0, dx = 0.0, dy = 0.0;
    const limit2 = 16.0;
    for (var i = 0; i < 24; i++) {
      final ndx = 2 * (zx * dx - zy * dy) + 1;
      final ndy = 2 * (zx * dy + zy * dx);
      dx = ndx;
      dy = ndy;
      final nzx = zx * zx - zy * zy + x;
      final nzy = 2 * zx * zy + y;
      zx = nzx;
      zy = nzy;
      if (zx * zx + zy * zy > limit2) {
        final r = math.max(math.sqrt(zx * zx + zy * zy), 1e-8);
        return math.max(0.0, 0.5 * r * math.log(r) /
            math.max(math.sqrt(dx * dx + dy * dy), 1e-8));
      }
    }
    return 0.0;
  }

  var worst = -1.0;
  for (var i = -5; i <= 5; i++) {
    for (var j = -5; j <= 5; j++) {
      for (var k = -5; k <= 5; k++) {
        final x = i / 5.0, y = j / 5.0, z = k / 5.0;
        final d0 = de(x, y - z);
        final d1 = de(x, y + z);
        final shipped = math.sqrt((d0 * d0 + d1 * d1) / 2);
        worst = math.max(worst, shipped - math.max(d0, d1));
      }
    }
  }
  return worst;
}
