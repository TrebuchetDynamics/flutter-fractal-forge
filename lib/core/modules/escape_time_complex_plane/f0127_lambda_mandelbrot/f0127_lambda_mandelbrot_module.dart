// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0127_lambda_mandelbrot_presets.dart';
import 'f0127_lambda_mandelbrot_variants.dart';
import 'f0127_lambda_mandelbrot_metadata.dart';

/// Lambda Mandelbrot — Escape-Time (Complex Plane).
class F0127LambdaMandelbrot extends EscapeTimeModule {
  F0127LambdaMandelbrot()
      : super(
          id: 'f0127_lambda_mandelbrot',
          shader: 'shaders/f0127_lambda_mandelbrot_gpu.frag',
        );

  @override
  F0127LambdaMandelbrotMetadata get metadata => F0127LambdaMandelbrotMetadata.instance;

  @override
  List<F0127LambdaMandelbrotPreset> get presets => F0127LambdaMandelbrotPresets.all;

  @override
  List<F0127LambdaMandelbrotVariant> get variants => F0127LambdaMandelbrotVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
