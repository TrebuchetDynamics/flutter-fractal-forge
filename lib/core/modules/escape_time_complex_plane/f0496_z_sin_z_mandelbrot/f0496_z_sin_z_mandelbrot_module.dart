// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0496_z_sin_z_mandelbrot_presets.dart';
import 'f0496_z_sin_z_mandelbrot_variants.dart';
import 'f0496_z_sin_z_mandelbrot_metadata.dart';

/// z + sin(z) Mandelbrot — Escape-Time (Complex Plane).
class F0496ZSinZMandelbrot extends EscapeTimeModule {
  F0496ZSinZMandelbrot()
      : super(
          id: 'f0496_z_sin_z_mandelbrot',
          shader: 'shaders/f0496_z_sin_z_mandelbrot_gpu.frag',
        );

  @override
  F0496ZSinZMandelbrotMetadata get metadata => F0496ZSinZMandelbrotMetadata.instance;

  @override
  List<F0496ZSinZMandelbrotPreset> get presets => F0496ZSinZMandelbrotPresets.all;

  @override
  List<F0496ZSinZMandelbrotVariant> get variants => F0496ZSinZMandelbrotVariants.all;

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
