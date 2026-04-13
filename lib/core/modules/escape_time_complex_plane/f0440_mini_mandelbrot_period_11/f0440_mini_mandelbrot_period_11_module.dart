// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0440_mini_mandelbrot_period_11_presets.dart';
import 'f0440_mini_mandelbrot_period_11_variants.dart';
import 'f0440_mini_mandelbrot_period_11_metadata.dart';

/// Mini Mandelbrot (period 11) — Escape-Time (Complex Plane).
class F0440MiniMandelbrotPeriod11 extends EscapeTimeModule {
  F0440MiniMandelbrotPeriod11()
      : super(
          id: 'f0440_mini_mandelbrot_period_11',
          shader: 'shaders/f0440_mini_mandelbrot_period_11_gpu.frag',
        );

  @override
  F0440MiniMandelbrotPeriod11Metadata get metadata => F0440MiniMandelbrotPeriod11Metadata.instance;

  @override
  List<F0440MiniMandelbrotPeriod11Preset> get presets => F0440MiniMandelbrotPeriod11Presets.all;

  @override
  List<F0440MiniMandelbrotPeriod11Variant> get variants => F0440MiniMandelbrotPeriod11Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 4000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
