// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0859_plant_abop_b_presets.dart';
import 'f0859_plant_abop_b_variants.dart';
import 'f0859_plant_abop_b_metadata.dart';

/// Plant ABOP B — L-Systems & Space-Filling.
class F0859PlantAbopB extends LSystemModule {
  F0859PlantAbopB()
      : super(
          id: 'f0859_plant_abop_b',
          shader: 'shaders/f0859_plant_abop_b_gpu.frag',
        );

  @override
  F0859PlantAbopBMetadata get metadata => F0859PlantAbopBMetadata.instance;

  @override
  List<F0859PlantAbopBPreset> get presets => F0859PlantAbopBPresets.all;

  @override
  List<F0859PlantAbopBVariant> get variants => F0859PlantAbopBVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
