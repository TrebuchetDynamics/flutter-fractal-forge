// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0181_twin_spiral_julia_presets.dart';
import 'f0181_twin_spiral_julia_variants.dart';
import 'f0181_twin_spiral_julia_metadata.dart';

/// Twin Spiral Julia — Escape-Time (Complex Plane).
class F0181TwinSpiralJulia extends EscapeTimeModule {
  F0181TwinSpiralJulia()
      : super(
          id: 'f0181_twin_spiral_julia',
          shader: 'shaders/f0181_twin_spiral_julia_gpu.frag',
        );

  @override
  F0181TwinSpiralJuliaMetadata get metadata => F0181TwinSpiralJuliaMetadata.instance;

  @override
  List<F0181TwinSpiralJuliaPreset> get presets => F0181TwinSpiralJuliaPresets.all;

  @override
  List<F0181TwinSpiralJuliaVariant> get variants => F0181TwinSpiralJuliaVariants.all;

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
