// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0434_mini_mandelbrot_period_5_presets.dart';
import 'f0434_mini_mandelbrot_period_5_variants.dart';
import 'f0434_mini_mandelbrot_period_5_metadata.dart';

/// Mini Mandelbrot (period 5) — Escape-Time (Complex Plane).
class F0434MiniMandelbrotPeriod5 extends EscapeTimeModule {
  F0434MiniMandelbrotPeriod5()
      : super(
          id: 'f0434_mini_mandelbrot_period_5',
          shader: 'shaders/f0434_mini_mandelbrot_period_5_gpu.frag',
        );

  @override
  F0434MiniMandelbrotPeriod5Metadata get metadata => F0434MiniMandelbrotPeriod5Metadata.instance;

  @override
  List<F0434MiniMandelbrotPeriod5Preset> get presets => F0434MiniMandelbrotPeriod5Presets.all;

  @override
  List<F0434MiniMandelbrotPeriod5Variant> get variants => F0434MiniMandelbrotPeriod5Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
