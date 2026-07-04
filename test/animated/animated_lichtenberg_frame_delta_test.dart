import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/features/renderer/validation/render_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

const _shaderAsset =
    'shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag';
const _width = 128;
const _height = 128;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'lichtenberg_growth has measurable frame progression at t=0, 0.5, 1.0',
    // Renders the real fragment shader; software-GL CI runners occasionally
    // produce a degenerate frame (their GPU probe logs invalid output), so
    // allow bounded retries for this environment-sensitive measurement.
    retry: 2,
    () async {
      final program = await ui.FragmentProgram.fromAsset(_shaderAsset);

      final frame0 = await _renderLichtenbergFrame(program, time: 0.0);
      final frame05 = await _renderLichtenbergFrame(program, time: 0.5);
      final frame1 = await _renderLichtenbergFrame(program, time: 1.0);

      final stats0 = validateRenderFrame(
        frame: frame0,
        width: _width,
        height: _height,
      );
      final stats05 = validateRenderFrame(
        frame: frame05,
        width: _width,
        height: _height,
      );
      final stats1 = validateRenderFrame(
        frame: frame1,
        width: _width,
        height: _height,
      );
      final delta0To05 = sampleRenderPair(
        frameA: frame0,
        frameB: frame05,
        width: _width,
        height: _height,
      );
      final delta05To1 = sampleRenderPair(
        frameA: frame05,
        frameB: frame1,
        width: _width,
        height: _height,
      );

      // Static share previews should be visible at t=0; later frames still
      // prove measurable animated growth.
      expect(stats0.histogramSane, isTrue);
      expect(stats05.histogramSane, isTrue);
      expect(stats1.histogramSane, isTrue);
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta0To05.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.frameProgressedFor(
          delta05To1.progressionRatio,
        ),
        isTrue,
      );
      expect(
        RenderValidationThresholds.defaults.iterationDeltaVisibleFor(
          delta05To1.progressionRatio,
        ),
        isTrue,
      );

      // Keep exact evidence visible in test logs for future threshold tuning.
      // ignore: avoid_print
      print(
        '[animated-lichtenberg] '
        'nonBlack=t0:${stats0.nonBlackRatio.toStringAsFixed(4)} '
        't05:${stats05.nonBlackRatio.toStringAsFixed(4)} '
        't1:${stats1.nonBlackRatio.toStringAsFixed(4)} '
        'delta0_05:${delta0To05.progressionRatio.toStringAsFixed(4)} '
        'delta05_1:${delta05To1.progressionRatio.toStringAsFixed(4)}',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

Future<Uint8List> _renderLichtenbergFrame(
  ui.FragmentProgram program, {
  required double time,
}) =>
    renderTestShaderFrame(
      program: program,
      shaderAsset: _shaderAsset,
      width: _width,
      height: _height,
      uniforms: [
        time,
        _width.toDouble(),
        _height.toDouble(),
        0.0, // uCenter.x
        0.0, // uCenter.y
        8.0, // uZoom: zoomed in so early growth is measurable
        50.0, // uIterations
        4.0, // uBailout
        0.0, // uColorScheme
        0.0, // uTransparentBg
        1.0, // uGrowthSpeed
        0.8, // uBranchAngle
        8.0, // uComplexity
      ],
    );
