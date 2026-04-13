// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0135_mandelbrot_power_d_1_25_presets.dart';
import 'f0135_mandelbrot_power_d_1_25_variants.dart';
import 'f0135_mandelbrot_power_d_1_25_metadata.dart';

/// Mandelbrot Power (d=1.25) — Escape-Time (Complex Plane).
class F0135MandelbrotPowerD125 extends EscapeTimeModule {
  F0135MandelbrotPowerD125()
      : super(
          id: 'f0135_mandelbrot_power_d_1_25',
          shader: 'shaders/f0135_mandelbrot_power_d_1_25_gpu.frag',
        );

  @override
  F0135MandelbrotPowerD125Metadata get metadata => F0135MandelbrotPowerD125Metadata.instance;

  @override
  List<F0135MandelbrotPowerD125Preset> get presets => F0135MandelbrotPowerD125Presets.all;

  @override
  List<F0135MandelbrotPowerD125Variant> get variants => F0135MandelbrotPowerD125Variants.all;

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
