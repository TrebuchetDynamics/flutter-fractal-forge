// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0437_mini_mandelbrot_period_8_presets.dart';
import 'f0437_mini_mandelbrot_period_8_variants.dart';
import 'f0437_mini_mandelbrot_period_8_metadata.dart';

/// Mini Mandelbrot (period 8) — Escape-Time (Complex Plane).
class F0437MiniMandelbrotPeriod8 extends EscapeTimeModule {
  F0437MiniMandelbrotPeriod8()
      : super(
          id: 'f0437_mini_mandelbrot_period_8',
          shader: 'shaders/f0437_mini_mandelbrot_period_8_gpu.frag',
        );

  @override
  F0437MiniMandelbrotPeriod8Metadata get metadata => F0437MiniMandelbrotPeriod8Metadata.instance;

  @override
  List<F0437MiniMandelbrotPeriod8Preset> get presets => F0437MiniMandelbrotPeriod8Presets.all;

  @override
  List<F0437MiniMandelbrotPeriod8Variant> get variants => F0437MiniMandelbrotPeriod8Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
