// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0149_cactus_julia_presets.dart';
import 'f0149_cactus_julia_variants.dart';
import 'f0149_cactus_julia_metadata.dart';

/// Cactus Julia — Escape-Time (Complex Plane).
class F0149CactusJulia extends EscapeTimeModule {
  F0149CactusJulia()
      : super(
          id: 'f0149_cactus_julia',
          shader: 'shaders/f0149_cactus_julia_gpu.frag',
        );

  @override
  F0149CactusJuliaMetadata get metadata => F0149CactusJuliaMetadata.instance;

  @override
  List<F0149CactusJuliaPreset> get presets => F0149CactusJuliaPresets.all;

  @override
  List<F0149CactusJuliaVariant> get variants => F0149CactusJuliaVariants.all;

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
