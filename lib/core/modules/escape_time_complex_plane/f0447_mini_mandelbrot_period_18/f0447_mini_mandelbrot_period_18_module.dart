// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0447_mini_mandelbrot_period_18_presets.dart';
import 'f0447_mini_mandelbrot_period_18_variants.dart';
import 'f0447_mini_mandelbrot_period_18_metadata.dart';

/// Mini Mandelbrot (period 18) — Escape-Time (Complex Plane).
class F0447MiniMandelbrotPeriod18 extends EscapeTimeModule {
  F0447MiniMandelbrotPeriod18()
      : super(
          id: 'f0447_mini_mandelbrot_period_18',
          shader: 'shaders/f0447_mini_mandelbrot_period_18_gpu.frag',
        );

  @override
  F0447MiniMandelbrotPeriod18Metadata get metadata => F0447MiniMandelbrotPeriod18Metadata.instance;

  @override
  List<F0447MiniMandelbrotPeriod18Preset> get presets => F0447MiniMandelbrotPeriod18Presets.all;

  @override
  List<F0447MiniMandelbrotPeriod18Variant> get variants => F0447MiniMandelbrotPeriod18Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 15000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
