// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0733_gray_scott_self_replicating_spots_presets.dart';
import 'f0733_gray_scott_self_replicating_spots_variants.dart';
import 'f0733_gray_scott_self_replicating_spots_metadata.dart';

/// Gray-Scott Self-Replicating Spots — Reaction-Diffusion & Chemical.
class F0733GrayScottSelfReplicatingSpots extends CellularModule {
  F0733GrayScottSelfReplicatingSpots()
      : super(
          id: 'f0733_gray_scott_self_replicating_spots',
          shader: 'shaders/f0733_gray_scott_self_replicating_spots_gpu.frag',
        );

  @override
  F0733GrayScottSelfReplicatingSpotsMetadata get metadata => F0733GrayScottSelfReplicatingSpotsMetadata.instance;

  @override
  List<F0733GrayScottSelfReplicatingSpotsPreset> get presets => F0733GrayScottSelfReplicatingSpotsPresets.all;

  @override
  List<F0733GrayScottSelfReplicatingSpotsVariant> get variants => F0733GrayScottSelfReplicatingSpotsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
