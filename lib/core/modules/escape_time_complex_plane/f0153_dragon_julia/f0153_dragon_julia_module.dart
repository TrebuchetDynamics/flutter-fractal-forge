// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0153_dragon_julia_presets.dart';
import 'f0153_dragon_julia_variants.dart';
import 'f0153_dragon_julia_metadata.dart';

/// Dragon Julia — Escape-Time (Complex Plane).
class F0153DragonJulia extends EscapeTimeModule {
  F0153DragonJulia()
      : super(
          id: 'f0153_dragon_julia',
          shader: 'shaders/f0153_dragon_julia_gpu.frag',
        );

  @override
  F0153DragonJuliaMetadata get metadata => F0153DragonJuliaMetadata.instance;

  @override
  List<F0153DragonJuliaPreset> get presets => F0153DragonJuliaPresets.all;

  @override
  List<F0153DragonJuliaVariant> get variants => F0153DragonJuliaVariants.all;

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
