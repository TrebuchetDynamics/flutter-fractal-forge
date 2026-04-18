// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0874_sea_coral_presets.dart';
import 'f0874_sea_coral_variants.dart';
import 'f0874_sea_coral_metadata.dart';

/// Sea Coral — L-Systems & Space-Filling.
class F0874SeaCoral extends LSystemModule {
  F0874SeaCoral()
      : super(
          id: 'f0874_sea_coral',
          shader: 'shaders/f0874_sea_coral_gpu.frag',
        );

  @override
  F0874SeaCoralMetadata get metadata => F0874SeaCoralMetadata.instance;

  @override
  List<F0874SeaCoralPreset> get presets => F0874SeaCoralPresets.all;

  @override
  List<F0874SeaCoralVariant> get variants => F0874SeaCoralVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
