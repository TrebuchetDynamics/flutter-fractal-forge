// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0436_mini_mandelbrot_period_7_presets.dart';
import 'f0436_mini_mandelbrot_period_7_variants.dart';
import 'f0436_mini_mandelbrot_period_7_metadata.dart';

/// Mini Mandelbrot (period 7) — Escape-Time (Complex Plane).
class F0436MiniMandelbrotPeriod7 extends EscapeTimeModule {
  F0436MiniMandelbrotPeriod7()
      : super(
          id: 'f0436_mini_mandelbrot_period_7',
          shader: 'shaders/f0436_mini_mandelbrot_period_7_gpu.frag',
        );

  @override
  F0436MiniMandelbrotPeriod7Metadata get metadata => F0436MiniMandelbrotPeriod7Metadata.instance;

  @override
  List<F0436MiniMandelbrotPeriod7Preset> get presets => F0436MiniMandelbrotPeriod7Presets.all;

  @override
  List<F0436MiniMandelbrotPeriod7Variant> get variants => F0436MiniMandelbrotPeriod7Variants.all;

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
