import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declared escape-time families color escaped values smoothly', () {
    final cases =
        <({String family, String path, RegExp formula, RegExp palette})>[
      (
        family: 'Phoenix memory map',
        path: 'shaders/escape_time_family/core/phoenix_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'quadratic legacy',
        path: 'shaders/legacy/escape_time/mandel_step_smooth.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*\+\s*4\.0\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'quadratic legacy',
        path: 'shaders/legacy/escape_time/julia.frag',
        formula: RegExp(
          r'iterations\s*=\s*float\(i\)\s*-\s*log2\(log2\(dot\(z,\s*z\)\)\)\s*\+\s*4\.0\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*iterations\s*/\s*uIterations'),
      ),
      (
        family: 'quadratic legacy',
        path: 'shaders/legacy/escape_time/burning_ship.frag',
        formula: RegExp(
          r'iterations\s*=\s*float\(i\)\s*-\s*log2\(log2\(dot\(z,\s*z\)\)\)\s*\+\s*4\.0\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*iterations\s*/\s*uIterations'),
      ),
      (
        family: 'quadratic perturbation',
        path: 'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(max\(1e-12,\s*finalMag2\)\)\)\s*\+\s*4\.0\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'integer-power polynomial',
        path:
            'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*\+\s*1\.0\s*-\s*log\(max\(1e-12,\s*logZn\)\)\s*/\s*log\(max\(1\.001,\s*abs\(power\)\)\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'integer-power polynomial',
        path: 'shaders/escape_time_family/polynomial_maps/druid_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*/\s*log2\(3\.0\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'rational escape map',
        path:
            'shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*/\s*log2\(nf\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'quadratic Buffalo',
        path: 'shaders/escape_time_family/families/buffalo/buffalo_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'cubic Buffalo',
        path:
            'shaders/escape_time_family/families/buffalo/buffalo_cubic_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*/\s*log2\(3\.0\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'transcendental map',
        path: 'shaders/escape_time_family/transcendental_maps/collatz_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'Feather map',
        path: 'shaders/escape_time_family/julia_variants/feather_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*/\s*log2\(3\.0\)\s*;',
        ),
        palette: RegExp(r'float\s+baseT\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'Feather map',
        path:
            'shaders/escape_time_family/julia_variants/feather_julia_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*/\s*log2\(3\.0\)\s*;',
        ),
        palette: RegExp(r'float\s+baseT\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
      (
        family: 'Shark Fin map',
        path: 'shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag',
        formula: RegExp(
          r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(mag2\)\)\s*;',
        ),
        palette: RegExp(r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0'),
      ),
    ];

    expect(cases.map((shaderCase) => shaderCase.path).toSet(),
        hasLength(cases.length));
    for (final shaderCase in cases) {
      final source = File(shaderCase.path).readAsStringSync();
      final insideBranch = RegExp(
        r'if\s*\(it\s*>=\s*(?:target|maxIter)\)[\s\S]*?return\s*;',
      ).firstMatch(source);
      final insideColorBranch = RegExp(
        r'if\s*\(dot\(z,\s*z\)\s*<=\s*bailoutSq\)[\s\S]*?fragColor\s*=\s*vec4\(0\.0,\s*0\.0,\s*0\.0,\s*1\.0\)',
      ).firstMatch(source);
      expect(
        insideBranch != null || insideColorBranch != null,
        isTrue,
        reason: '${shaderCase.path} has distinct inside-set output',
      );

      final formula = shaderCase.formula.firstMatch(source);
      expect(formula, isNotNull,
          reason: '${shaderCase.family}: ${shaderCase.path} uses its formula');
      final palette = shaderCase.palette.firstMatch(source);
      expect(palette, isNotNull,
          reason:
              '${shaderCase.path} derives palette coordinate from smooth value');
      expect(palette!.start, greaterThan(formula!.end),
          reason:
              '${shaderCase.path} colors only after its escape value is smoothed');
      if (shaderCase.family == 'Shark Fin map') {
        expect(
          RegExp(r'palette\s*\(\s*t\s*,\s*schemeInt\s*\)').hasMatch(source),
          isTrue,
          reason:
              '${shaderCase.path} passes the smoothed coordinate to palette',
        );
      }
      if (shaderCase.family == 'Phoenix memory map') {
        expect(
          RegExp(r'palette\s*\(\s*t\s*,\s*schemeInt\s*\)').hasMatch(source),
          isTrue,
          reason: '${shaderCase.path} colors with the smooth palette value',
        );
      }
    }
  });

  test('Phoenix smooth magnitude changes its palette coordinate', () {
    const shaderPath = 'shaders/escape_time_family/core/phoenix_gpu.frag';
    final source = File(shaderPath).readAsStringSync();
    expect(
      source,
      contains('float smoothVal = float(it) - log2(log2(mag2));'),
    );
    expect(source,
        contains('float t = fract(smoothVal / 64.0 + uTime * 0.0001);'));
    expect(source, contains('palette(t, schemeInt)'));

    double paletteCoordinate(int iterations, double magnitudeSquared) {
      final smoothValue = iterations -
          (math.log(math.log(magnitudeSquared) / math.ln2) / math.ln2);
      return (smoothValue / 64.0) % 1.0;
    }

    final smoothedCoordinate = paletteCoordinate(3, 16.0);
    expect(smoothedCoordinate, closeTo(1.0 / 64.0, 1e-12));
    expect(smoothedCoordinate, isNot(closeTo(3.0 / 64.0, 1e-12)));
  });
}
