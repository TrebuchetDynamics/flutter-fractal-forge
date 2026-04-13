// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0435_mini_mandelbrot_period_6_presets.dart';
import 'f0435_mini_mandelbrot_period_6_variants.dart';
import 'f0435_mini_mandelbrot_period_6_metadata.dart';

/// Mini Mandelbrot (period 6) — Escape-Time (Complex Plane).
class F0435MiniMandelbrotPeriod6 extends EscapeTimeModule {
  F0435MiniMandelbrotPeriod6()
      : super(
          id: 'f0435_mini_mandelbrot_period_6',
          shader: 'shaders/f0435_mini_mandelbrot_period_6_gpu.frag',
        );

  @override
  F0435MiniMandelbrotPeriod6Metadata get metadata => F0435MiniMandelbrotPeriod6Metadata.instance;

  @override
  List<F0435MiniMandelbrotPeriod6Preset> get presets => F0435MiniMandelbrotPeriod6Presets.all;

  @override
  List<F0435MiniMandelbrotPeriod6Variant> get variants => F0435MiniMandelbrotPeriod6Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
