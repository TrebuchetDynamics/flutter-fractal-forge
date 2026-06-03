import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_test/flutter_test.dart';

FractalModule _module({
  required String id,
  String? shaderAsset,
}) {
  return FractalModule(
    id: id,
    displayName: (_) => id,
    dimension: FractalDimension.twoD,
    shaderAsset: shaderAsset ?? 'shaders/$id.frag',
    parameters: const [],
    defaultPreset: FractalPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Default',
      params: const {},
      view: FractalViewState.initial(),
      createdAt: DateTime(2026),
      isBuiltIn: true,
    ),
    builtInPresets: const [],
    setUniforms: (_, __, ___, ____) {},
  );
}

void main() {
  group('ViewerRandomFractalCandidate', () {
    test('excludes the currently selected module by exact id', () {
      final decision = ViewerRandomFractalCandidate.fromModule(
        _module(id: 'mandelbrot'),
        currentModuleId: 'mandelbrot',
      );

      expect(decision.moduleId, 'mandelbrot');
      expect(decision.reason, ViewerRandomFractalCandidateReason.currentModule);
      expect(decision.isEligible, isFalse);
    });

    test('keeps real catalog ids containing diag eligible', () {
      final decision = ViewerRandomFractalCandidate.fromModule(
        _module(id: 'farey_diagram'),
        currentModuleId: 'mandelbrot',
      );

      expect(decision.reason, ViewerRandomFractalCandidateReason.eligible);
      expect(decision.isEligible, isTrue);
    });

    test('excludes debug diagnostic modules from random navigation', () {
      final decisions = [
        ViewerRandomFractalCandidate.fromModule(
          _module(
            id: 'test_minimal',
            shaderAsset: 'shaders/diagnostic/test_minimal.frag',
          ),
          currentModuleId: 'mandelbrot',
        ),
        ViewerRandomFractalCandidate.fromModule(
          _module(id: 'gpu_gradient'),
          currentModuleId: 'mandelbrot',
        ),
        ViewerRandomFractalCandidate.fromModule(
          _module(id: 'gpu_sampler_diag'),
          currentModuleId: 'mandelbrot',
        ),
      ];

      expect(
        decisions.map((decision) => decision.reason),
        everyElement(ViewerRandomFractalCandidateReason.diagnosticModule),
      );
      expect(decisions.map((decision) => decision.isEligible),
          everyElement(isFalse));
    });
  });
}
