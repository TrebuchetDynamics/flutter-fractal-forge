// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0495_z_sin_z_mandelbrot_presets.dart';
import 'f0495_z_sin_z_mandelbrot_variants.dart';
import 'f0495_z_sin_z_mandelbrot_metadata.dart';

/// z·sin(z) Mandelbrot — Escape-Time (Complex Plane).
class F0495ZSinZMandelbrot extends EscapeTimeModule {
  F0495ZSinZMandelbrot()
      : super(
          id: 'f0495_z_sin_z_mandelbrot',
          shader: 'shaders/f0495_z_sin_z_mandelbrot_gpu.frag',
        );

  @override
  F0495ZSinZMandelbrotMetadata get metadata => F0495ZSinZMandelbrotMetadata.instance;

  @override
  List<F0495ZSinZMandelbrotPreset> get presets => F0495ZSinZMandelbrotPresets.all;

  @override
  List<F0495ZSinZMandelbrotVariant> get variants => F0495ZSinZMandelbrotVariants.all;

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
