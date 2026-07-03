import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import '../helpers/render_test_shader.dart';

void main() {
  const shaderAsset =
      'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_julia_gpu.frag';

  test('Burning Ship Julia shader uses upright Julia mapping and orbit detail',
      () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('vec2(uv.x, -uv.y)'));
    expect(shader, contains('vec2(uCenter.x, -uCenter.y)'));
    expect(shader, contains('vec2 cSeed = vec2(-0.52, -0.42);'));
    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('orbit += exp(-1.7 * mag2);'));
    expect(shader, contains('float trapGlow = exp(-9.0 * trap);'));
  });

  test('Burning Ship Julia shader compiles as a runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(shaderAsset), isNotNull);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('reported share view renders non-flat Burning Ship Julia detail',
      () async {
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);
    final bytes = await renderTestShaderFrame(
      program: program,
      shaderAsset: shaderAsset,
      width: 64,
      height: 64,
      uniforms: const [
        0.0, // uTime
        64.0, // uResolution.x
        64.0, // uResolution.y
        0.07873259484767914, // uCenter.x from report
        0.1843518614768982, // uCenter.y from report
        0.3304664087905834, // uZoom from report
        337.0, // uIterations from report
        4.0, // uBailout from report
        0.0, // uColorScheme from report
        0.0, // uTransparentBg
      ],
    );

    expect(_uniqueSampledColors(bytes), greaterThan(24));
    expect(_lumaRange(bytes), greaterThan(35));
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('Burning Ship Julia CPU fallback is the real fixed-seed map', () {
    final source =
        File('lib/features/renderer/cpu/cpu_formulas.dart').readAsStringSync();
    expect(source, isNot(contains('_cpu_synthetic(0x9921bde9')));

    final formula = cpuFormulaForModuleId('burning_ship_julia');
    final center = formula(0.0, 0.0, 337, 4.0, Vector2.zero());
    final offset = formula(0.12, 0.18, 337, 4.0, Vector2.zero());
    final exterior = formula(1.0, 1.0, 337, 4.0, Vector2.zero());

    expect(_rgbDistance(center, offset), greaterThan(5.0));
    expect(_rgbDistance(center, exterior), greaterThan(20.0));
  });

  test('Burning Ship Julia keeps GPU detail until escape-time CPU threshold',
      () {
    const policy = PrecisionLadderPolicy();

    final midDeepZoom = policy.decide(
      moduleId: 'burning_ship_julia',
      dimension: FractalDimension.twoD,
      zoom: 5e7,
    );
    final cpuZoom = policy.decide(
      moduleId: 'burning_ship_julia',
      dimension: FractalDimension.twoD,
      zoom: 1e31,
    );

    expect(midDeepZoom.renderPath, PrecisionLadderRenderPath.gpuPerturbation);
    expect(cpuZoom.renderPath, PrecisionLadderRenderPath.cpu);
  });
}

double _rgbDistance(
  (double r, double g, double b) a,
  (double r, double g, double b) b,
) {
  final dr = a.$1 - b.$1;
  final dg = a.$2 - b.$2;
  final db = a.$3 - b.$3;
  return dr.abs() + dg.abs() + db.abs();
}

int _uniqueSampledColors(List<int> bytes) {
  final colors = <int>{};
  for (var i = 0; i < bytes.length; i += 16) {
    colors.add((bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]);
  }
  return colors.length;
}

int _lumaRange(List<int> bytes) {
  var minLuma = 255;
  var maxLuma = 0;
  for (var i = 0; i < bytes.length; i += 4) {
    final luma =
        ((bytes[i] * 299 + bytes[i + 1] * 587 + bytes[i + 2] * 114) / 1000)
            .round();
    if (luma < minLuma) minLuma = luma;
    if (luma > maxLuma) maxLuma = luma;
  }
  return maxLuma - minLuma;
}
