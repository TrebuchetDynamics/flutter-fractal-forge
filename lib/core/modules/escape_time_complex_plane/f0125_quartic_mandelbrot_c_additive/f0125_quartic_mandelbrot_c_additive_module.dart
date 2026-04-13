// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0125_quartic_mandelbrot_c_additive_presets.dart';
import 'f0125_quartic_mandelbrot_c_additive_variants.dart';
import 'f0125_quartic_mandelbrot_c_additive_metadata.dart';

/// Quartic Mandelbrot (c-additive) — Escape-Time (Complex Plane).
class F0125QuarticMandelbrotCAdditive extends EscapeTimeModule {
  F0125QuarticMandelbrotCAdditive()
      : super(
          id: 'f0125_quartic_mandelbrot_c_additive',
          shader: 'shaders/f0125_quartic_mandelbrot_c_additive_gpu.frag',
        );

  @override
  F0125QuarticMandelbrotCAdditiveMetadata get metadata => F0125QuarticMandelbrotCAdditiveMetadata.instance;

  @override
  List<F0125QuarticMandelbrotCAdditivePreset> get presets => F0125QuarticMandelbrotCAdditivePresets.all;

  @override
  List<F0125QuarticMandelbrotCAdditiveVariant> get variants => F0125QuarticMandelbrotCAdditiveVariants.all;

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
