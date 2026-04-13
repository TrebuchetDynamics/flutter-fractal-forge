// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0443_mini_mandelbrot_period_14_presets.dart';
import 'f0443_mini_mandelbrot_period_14_variants.dart';
import 'f0443_mini_mandelbrot_period_14_metadata.dart';

/// Mini Mandelbrot (period 14) — Escape-Time (Complex Plane).
class F0443MiniMandelbrotPeriod14 extends EscapeTimeModule {
  F0443MiniMandelbrotPeriod14()
      : super(
          id: 'f0443_mini_mandelbrot_period_14',
          shader: 'shaders/f0443_mini_mandelbrot_period_14_gpu.frag',
        );

  @override
  F0443MiniMandelbrotPeriod14Metadata get metadata => F0443MiniMandelbrotPeriod14Metadata.instance;

  @override
  List<F0443MiniMandelbrotPeriod14Preset> get presets => F0443MiniMandelbrotPeriod14Presets.all;

  @override
  List<F0443MiniMandelbrotPeriod14Variant> get variants => F0443MiniMandelbrotPeriod14Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 8000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
