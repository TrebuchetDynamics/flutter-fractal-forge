// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0449_mini_mandelbrot_period_20_presets.dart';
import 'f0449_mini_mandelbrot_period_20_variants.dart';
import 'f0449_mini_mandelbrot_period_20_metadata.dart';

/// Mini Mandelbrot (period 20) — Escape-Time (Complex Plane).
class F0449MiniMandelbrotPeriod20 extends EscapeTimeModule {
  F0449MiniMandelbrotPeriod20()
      : super(
          id: 'f0449_mini_mandelbrot_period_20',
          shader: 'shaders/f0449_mini_mandelbrot_period_20_gpu.frag',
        );

  @override
  F0449MiniMandelbrotPeriod20Metadata get metadata => F0449MiniMandelbrotPeriod20Metadata.instance;

  @override
  List<F0449MiniMandelbrotPeriod20Preset> get presets => F0449MiniMandelbrotPeriod20Presets.all;

  @override
  List<F0449MiniMandelbrotPeriod20Variant> get variants => F0449MiniMandelbrotPeriod20Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 50000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
