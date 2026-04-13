// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0164_spiral_julia_presets.dart';
import 'f0164_spiral_julia_variants.dart';
import 'f0164_spiral_julia_metadata.dart';

/// Spiral Julia — Escape-Time (Complex Plane).
class F0164SpiralJulia extends EscapeTimeModule {
  F0164SpiralJulia()
      : super(
          id: 'f0164_spiral_julia',
          shader: 'shaders/f0164_spiral_julia_gpu.frag',
        );

  @override
  F0164SpiralJuliaMetadata get metadata => F0164SpiralJuliaMetadata.instance;

  @override
  List<F0164SpiralJuliaPreset> get presets => F0164SpiralJuliaPresets.all;

  @override
  List<F0164SpiralJuliaVariant> get variants => F0164SpiralJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
