// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0433_mini_mandelbrot_period_4_presets.dart';
import 'f0433_mini_mandelbrot_period_4_variants.dart';
import 'f0433_mini_mandelbrot_period_4_metadata.dart';

/// Mini Mandelbrot (period 4) — Escape-Time (Complex Plane).
class F0433MiniMandelbrotPeriod4 extends EscapeTimeModule {
  F0433MiniMandelbrotPeriod4()
      : super(
          id: 'f0433_mini_mandelbrot_period_4',
          shader: 'shaders/f0433_mini_mandelbrot_period_4_gpu.frag',
        );

  @override
  F0433MiniMandelbrotPeriod4Metadata get metadata => F0433MiniMandelbrotPeriod4Metadata.instance;

  @override
  List<F0433MiniMandelbrotPeriod4Preset> get presets => F0433MiniMandelbrotPeriod4Presets.all;

  @override
  List<F0433MiniMandelbrotPeriod4Variant> get variants => F0433MiniMandelbrotPeriod4Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
