// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0445_mini_mandelbrot_period_16_presets.dart';
import 'f0445_mini_mandelbrot_period_16_variants.dart';
import 'f0445_mini_mandelbrot_period_16_metadata.dart';

/// Mini Mandelbrot (period 16) — Escape-Time (Complex Plane).
class F0445MiniMandelbrotPeriod16 extends EscapeTimeModule {
  F0445MiniMandelbrotPeriod16()
      : super(
          id: 'f0445_mini_mandelbrot_period_16',
          shader: 'shaders/f0445_mini_mandelbrot_period_16_gpu.frag',
        );

  @override
  F0445MiniMandelbrotPeriod16Metadata get metadata => F0445MiniMandelbrotPeriod16Metadata.instance;

  @override
  List<F0445MiniMandelbrotPeriod16Preset> get presets => F0445MiniMandelbrotPeriod16Presets.all;

  @override
  List<F0445MiniMandelbrotPeriod16Variant> get variants => F0445MiniMandelbrotPeriod16Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 12000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
