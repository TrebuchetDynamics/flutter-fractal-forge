// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0439_mini_mandelbrot_period_10_presets.dart';
import 'f0439_mini_mandelbrot_period_10_variants.dart';
import 'f0439_mini_mandelbrot_period_10_metadata.dart';

/// Mini Mandelbrot (period 10) — Escape-Time (Complex Plane).
class F0439MiniMandelbrotPeriod10 extends EscapeTimeModule {
  F0439MiniMandelbrotPeriod10()
      : super(
          id: 'f0439_mini_mandelbrot_period_10',
          shader: 'shaders/f0439_mini_mandelbrot_period_10_gpu.frag',
        );

  @override
  F0439MiniMandelbrotPeriod10Metadata get metadata => F0439MiniMandelbrotPeriod10Metadata.instance;

  @override
  List<F0439MiniMandelbrotPeriod10Preset> get presets => F0439MiniMandelbrotPeriod10Presets.all;

  @override
  List<F0439MiniMandelbrotPeriod10Variant> get variants => F0439MiniMandelbrotPeriod10Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
