// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0494_z_exp_z_mandelbrot_presets.dart';
import 'f0494_z_exp_z_mandelbrot_variants.dart';
import 'f0494_z_exp_z_mandelbrot_metadata.dart';

/// z·exp(z) Mandelbrot — Escape-Time (Complex Plane).
class F0494ZExpZMandelbrot extends EscapeTimeModule {
  F0494ZExpZMandelbrot()
      : super(
          id: 'f0494_z_exp_z_mandelbrot',
          shader: 'shaders/f0494_z_exp_z_mandelbrot_gpu.frag',
        );

  @override
  F0494ZExpZMandelbrotMetadata get metadata => F0494ZExpZMandelbrotMetadata.instance;

  @override
  List<F0494ZExpZMandelbrotPreset> get presets => F0494ZExpZMandelbrotPresets.all;

  @override
  List<F0494ZExpZMandelbrotVariant> get variants => F0494ZExpZMandelbrotVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
