// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0432_mini_mandelbrot_period_3_presets.dart';
import 'f0432_mini_mandelbrot_period_3_variants.dart';
import 'f0432_mini_mandelbrot_period_3_metadata.dart';

/// Mini Mandelbrot (period 3) — Escape-Time (Complex Plane).
class F0432MiniMandelbrotPeriod3 extends EscapeTimeModule {
  F0432MiniMandelbrotPeriod3()
      : super(
          id: 'f0432_mini_mandelbrot_period_3',
          shader: 'shaders/f0432_mini_mandelbrot_period_3_gpu.frag',
        );

  @override
  F0432MiniMandelbrotPeriod3Metadata get metadata => F0432MiniMandelbrotPeriod3Metadata.instance;

  @override
  List<F0432MiniMandelbrotPeriod3Preset> get presets => F0432MiniMandelbrotPeriod3Presets.all;

  @override
  List<F0432MiniMandelbrotPeriod3Variant> get variants => F0432MiniMandelbrotPeriod3Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 800;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
