// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0134_mandelbrot_power_d_2_7_presets.dart';
import 'f0134_mandelbrot_power_d_2_7_variants.dart';
import 'f0134_mandelbrot_power_d_2_7_metadata.dart';

/// Mandelbrot Power (d=2.7) — Escape-Time (Complex Plane).
class F0134MandelbrotPowerD27 extends EscapeTimeModule {
  F0134MandelbrotPowerD27()
      : super(
          id: 'f0134_mandelbrot_power_d_2_7',
          shader: 'shaders/f0134_mandelbrot_power_d_2_7_gpu.frag',
        );

  @override
  F0134MandelbrotPowerD27Metadata get metadata => F0134MandelbrotPowerD27Metadata.instance;

  @override
  List<F0134MandelbrotPowerD27Preset> get presets => F0134MandelbrotPowerD27Presets.all;

  @override
  List<F0134MandelbrotPowerD27Variant> get variants => F0134MandelbrotPowerD27Variants.all;

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
