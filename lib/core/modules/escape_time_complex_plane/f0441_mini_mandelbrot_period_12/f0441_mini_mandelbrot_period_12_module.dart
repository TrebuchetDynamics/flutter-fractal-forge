// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0441_mini_mandelbrot_period_12_presets.dart';
import 'f0441_mini_mandelbrot_period_12_variants.dart';
import 'f0441_mini_mandelbrot_period_12_metadata.dart';

/// Mini Mandelbrot (period 12) — Escape-Time (Complex Plane).
class F0441MiniMandelbrotPeriod12 extends EscapeTimeModule {
  F0441MiniMandelbrotPeriod12()
      : super(
          id: 'f0441_mini_mandelbrot_period_12',
          shader: 'shaders/f0441_mini_mandelbrot_period_12_gpu.frag',
        );

  @override
  F0441MiniMandelbrotPeriod12Metadata get metadata => F0441MiniMandelbrotPeriod12Metadata.instance;

  @override
  List<F0441MiniMandelbrotPeriod12Preset> get presets => F0441MiniMandelbrotPeriod12Presets.all;

  @override
  List<F0441MiniMandelbrotPeriod12Variant> get variants => F0441MiniMandelbrotPeriod12Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 5000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
