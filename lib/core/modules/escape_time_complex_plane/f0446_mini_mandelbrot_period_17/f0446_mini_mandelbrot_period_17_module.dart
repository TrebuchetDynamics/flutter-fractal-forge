// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0446_mini_mandelbrot_period_17_presets.dart';
import 'f0446_mini_mandelbrot_period_17_variants.dart';
import 'f0446_mini_mandelbrot_period_17_metadata.dart';

/// Mini Mandelbrot (period 17) — Escape-Time (Complex Plane).
class F0446MiniMandelbrotPeriod17 extends EscapeTimeModule {
  F0446MiniMandelbrotPeriod17()
      : super(
          id: 'f0446_mini_mandelbrot_period_17',
          shader: 'shaders/f0446_mini_mandelbrot_period_17_gpu.frag',
        );

  @override
  F0446MiniMandelbrotPeriod17Metadata get metadata => F0446MiniMandelbrotPeriod17Metadata.instance;

  @override
  List<F0446MiniMandelbrotPeriod17Preset> get presets => F0446MiniMandelbrotPeriod17Presets.all;

  @override
  List<F0446MiniMandelbrotPeriod17Variant> get variants => F0446MiniMandelbrotPeriod17Variants.all;

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
