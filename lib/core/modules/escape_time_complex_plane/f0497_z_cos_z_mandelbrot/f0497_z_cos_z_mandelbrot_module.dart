// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0497_z_cos_z_mandelbrot_presets.dart';
import 'f0497_z_cos_z_mandelbrot_variants.dart';
import 'f0497_z_cos_z_mandelbrot_metadata.dart';

/// z + cos(z) Mandelbrot — Escape-Time (Complex Plane).
class F0497ZCosZMandelbrot extends EscapeTimeModule {
  F0497ZCosZMandelbrot()
      : super(
          id: 'f0497_z_cos_z_mandelbrot',
          shader: 'shaders/f0497_z_cos_z_mandelbrot_gpu.frag',
        );

  @override
  F0497ZCosZMandelbrotMetadata get metadata => F0497ZCosZMandelbrotMetadata.instance;

  @override
  List<F0497ZCosZMandelbrotPreset> get presets => F0497ZCosZMandelbrotPresets.all;

  @override
  List<F0497ZCosZMandelbrotVariant> get variants => F0497ZCosZMandelbrotVariants.all;

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
