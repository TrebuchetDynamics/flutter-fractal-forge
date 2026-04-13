// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0475_mandelbrot_antenna_presets.dart';
import 'f0475_mandelbrot_antenna_variants.dart';
import 'f0475_mandelbrot_antenna_metadata.dart';

/// Mandelbrot Antenna — Escape-Time (Complex Plane).
class F0475MandelbrotAntenna extends EscapeTimeModule {
  F0475MandelbrotAntenna()
      : super(
          id: 'f0475_mandelbrot_antenna',
          shader: 'shaders/f0475_mandelbrot_antenna_gpu.frag',
        );

  @override
  F0475MandelbrotAntennaMetadata get metadata => F0475MandelbrotAntennaMetadata.instance;

  @override
  List<F0475MandelbrotAntennaPreset> get presets => F0475MandelbrotAntennaPresets.all;

  @override
  List<F0475MandelbrotAntennaVariant> get variants => F0475MandelbrotAntennaVariants.all;

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
