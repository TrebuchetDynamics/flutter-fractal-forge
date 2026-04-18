// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0793_sacks_spiral_presets.dart';
import 'f0793_sacks_spiral_variants.dart';
import 'f0793_sacks_spiral_metadata.dart';

/// Sacks Spiral — Number-Theory Fractals.
class F0793SacksSpiral extends CellularModule {
  F0793SacksSpiral()
      : super(
          id: 'f0793_sacks_spiral',
          shader: 'shaders/f0793_sacks_spiral_gpu.frag',
        );

  @override
  F0793SacksSpiralMetadata get metadata => F0793SacksSpiralMetadata.instance;

  @override
  List<F0793SacksSpiralPreset> get presets => F0793SacksSpiralPresets.all;

  @override
  List<F0793SacksSpiralVariant> get variants => F0793SacksSpiralVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
