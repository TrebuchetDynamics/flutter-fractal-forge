// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0442_mini_mandelbrot_period_13_presets.dart';
import 'f0442_mini_mandelbrot_period_13_variants.dart';
import 'f0442_mini_mandelbrot_period_13_metadata.dart';

/// Mini Mandelbrot (period 13) — Escape-Time (Complex Plane).
class F0442MiniMandelbrotPeriod13 extends EscapeTimeModule {
  F0442MiniMandelbrotPeriod13()
      : super(
          id: 'f0442_mini_mandelbrot_period_13',
          shader: 'shaders/f0442_mini_mandelbrot_period_13_gpu.frag',
        );

  @override
  F0442MiniMandelbrotPeriod13Metadata get metadata => F0442MiniMandelbrotPeriod13Metadata.instance;

  @override
  List<F0442MiniMandelbrotPeriod13Preset> get presets => F0442MiniMandelbrotPeriod13Presets.all;

  @override
  List<F0442MiniMandelbrotPeriod13Variant> get variants => F0442MiniMandelbrotPeriod13Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 6000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
