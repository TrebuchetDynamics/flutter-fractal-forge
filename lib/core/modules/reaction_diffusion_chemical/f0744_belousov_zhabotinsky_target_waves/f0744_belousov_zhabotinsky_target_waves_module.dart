// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0744_belousov_zhabotinsky_target_waves_presets.dart';
import 'f0744_belousov_zhabotinsky_target_waves_variants.dart';
import 'f0744_belousov_zhabotinsky_target_waves_metadata.dart';

/// Belousov-Zhabotinsky Target Waves — Reaction-Diffusion & Chemical.
class F0744BelousovZhabotinskyTargetWaves extends CellularModule {
  F0744BelousovZhabotinskyTargetWaves()
      : super(
          id: 'f0744_belousov_zhabotinsky_target_waves',
          shader: 'shaders/f0744_belousov_zhabotinsky_target_waves_gpu.frag',
        );

  @override
  F0744BelousovZhabotinskyTargetWavesMetadata get metadata => F0744BelousovZhabotinskyTargetWavesMetadata.instance;

  @override
  List<F0744BelousovZhabotinskyTargetWavesPreset> get presets => F0744BelousovZhabotinskyTargetWavesPresets.all;

  @override
  List<F0744BelousovZhabotinskyTargetWavesVariant> get variants => F0744BelousovZhabotinskyTargetWavesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
