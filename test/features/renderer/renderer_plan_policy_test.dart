import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/policy/backend_policy.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_fractals/features/renderer/policy/render_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const precisionPolicy = PrecisionLadderPolicy();
  const planPolicy = RendererPlanPolicy();

  test('routes CPU precision decisions to CPU backend in auto mode', () {
    final plan = planPolicy.decide(
      precision: precisionPolicy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      ),
      userMode: RendererBackendMode.auto,
      gpuHealthFailed: false,
      isAndroid: false,
      isWeb: false,
      isEmulator: false,
    );

    expect(plan.precision.renderPath, PrecisionLadderRenderPath.cpu);
    expect(plan.backend.backend, RendererBackend.cpu);
    expect(plan.backend.reasonCode, FallbackReasonCode.deepZoomPrecision);
  });

  test('keeps extended GPU preview on GPU in auto mode', () {
    final plan = planPolicy.decide(
      precision: precisionPolicy.decide(
        moduleId: 'julia',
        dimension: FractalDimension.twoD,
        zoom: 1e10,
      ),
      userMode: RendererBackendMode.auto,
      gpuHealthFailed: false,
      isAndroid: false,
      isWeb: false,
      isEmulator: false,
    );

    expect(
        plan.precision.renderPath, PrecisionLadderRenderPath.gpuPerturbation);
    expect(plan.backend.backend, RendererBackend.gpu);
  });

  test('resolves effective modules for extended GPU paths', () {
    final registry = ModuleRegistry();
    final resolver = RendererPlanModuleResolver();

    final mandelbrot = registry.byId('mandelbrot');
    final df2 = resolver.resolve(
      plan: RendererPlan.gpu(
        precisionPolicy.decide(
          moduleId: 'mandelbrot',
          dimension: FractalDimension.twoD,
          zoom: 1e10,
        ),
      ),
      module: mandelbrot,
    );
    expect(df2.shaderAsset, 'shaders/legacy/precision/mandelbrot_df2.frag');

    final julia = registry.byId('julia');
    final perturb = resolver.resolve(
      plan: RendererPlan.gpu(
        precisionPolicy.decide(
          moduleId: 'julia',
          dimension: FractalDimension.twoD,
          zoom: 1e10,
        ),
      ),
      module: julia,
    );
    expect(
      perturb.shaderAsset,
      'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
    );

    final ordinary = resolver.resolve(
      plan: RendererPlan.gpu(
        precisionPolicy.decide(
          moduleId: 'julia',
          dimension: FractalDimension.twoD,
          zoom: 1,
        ),
      ),
      module: julia,
    );
    expect(identical(ordinary, julia), isTrue);
  });
}
