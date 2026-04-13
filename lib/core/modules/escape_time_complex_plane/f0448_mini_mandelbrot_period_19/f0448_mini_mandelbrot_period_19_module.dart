// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0448_mini_mandelbrot_period_19_presets.dart';
import 'f0448_mini_mandelbrot_period_19_variants.dart';
import 'f0448_mini_mandelbrot_period_19_metadata.dart';

/// Mini Mandelbrot (period 19) — Escape-Time (Complex Plane).
class F0448MiniMandelbrotPeriod19 extends EscapeTimeModule {
  F0448MiniMandelbrotPeriod19()
      : super(
          id: 'f0448_mini_mandelbrot_period_19',
          shader: 'shaders/f0448_mini_mandelbrot_period_19_gpu.frag',
        );

  @override
  F0448MiniMandelbrotPeriod19Metadata get metadata => F0448MiniMandelbrotPeriod19Metadata.instance;

  @override
  List<F0448MiniMandelbrotPeriod19Preset> get presets => F0448MiniMandelbrotPeriod19Presets.all;

  @override
  List<F0448MiniMandelbrotPeriod19Variant> get variants => F0448MiniMandelbrotPeriod19Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 25000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
