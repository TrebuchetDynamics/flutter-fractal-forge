// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0438_mini_mandelbrot_period_9_presets.dart';
import 'f0438_mini_mandelbrot_period_9_variants.dart';
import 'f0438_mini_mandelbrot_period_9_metadata.dart';

/// Mini Mandelbrot (period 9) — Escape-Time (Complex Plane).
class F0438MiniMandelbrotPeriod9 extends EscapeTimeModule {
  F0438MiniMandelbrotPeriod9()
      : super(
          id: 'f0438_mini_mandelbrot_period_9',
          shader: 'shaders/f0438_mini_mandelbrot_period_9_gpu.frag',
        );

  @override
  F0438MiniMandelbrotPeriod9Metadata get metadata => F0438MiniMandelbrotPeriod9Metadata.instance;

  @override
  List<F0438MiniMandelbrotPeriod9Preset> get presets => F0438MiniMandelbrotPeriod9Presets.all;

  @override
  List<F0438MiniMandelbrotPeriod9Variant> get variants => F0438MiniMandelbrotPeriod9Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
