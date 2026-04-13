// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0444_mini_mandelbrot_period_15_presets.dart';
import 'f0444_mini_mandelbrot_period_15_variants.dart';
import 'f0444_mini_mandelbrot_period_15_metadata.dart';

/// Mini Mandelbrot (period 15) — Escape-Time (Complex Plane).
class F0444MiniMandelbrotPeriod15 extends EscapeTimeModule {
  F0444MiniMandelbrotPeriod15()
      : super(
          id: 'f0444_mini_mandelbrot_period_15',
          shader: 'shaders/f0444_mini_mandelbrot_period_15_gpu.frag',
        );

  @override
  F0444MiniMandelbrotPeriod15Metadata get metadata => F0444MiniMandelbrotPeriod15Metadata.instance;

  @override
  List<F0444MiniMandelbrotPeriod15Preset> get presets => F0444MiniMandelbrotPeriod15Presets.all;

  @override
  List<F0444MiniMandelbrotPeriod15Variant> get variants => F0444MiniMandelbrotPeriod15Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 10000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
