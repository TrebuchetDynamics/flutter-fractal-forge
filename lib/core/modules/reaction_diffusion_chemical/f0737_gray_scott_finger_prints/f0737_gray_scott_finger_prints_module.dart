// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0737_gray_scott_finger_prints_presets.dart';
import 'f0737_gray_scott_finger_prints_variants.dart';
import 'f0737_gray_scott_finger_prints_metadata.dart';

/// Gray-Scott Finger Prints — Reaction-Diffusion & Chemical.
class F0737GrayScottFingerPrints extends CellularModule {
  F0737GrayScottFingerPrints()
      : super(
          id: 'f0737_gray_scott_finger_prints',
          shader: 'shaders/f0737_gray_scott_finger_prints_gpu.frag',
        );

  @override
  F0737GrayScottFingerPrintsMetadata get metadata => F0737GrayScottFingerPrintsMetadata.instance;

  @override
  List<F0737GrayScottFingerPrintsPreset> get presets => F0737GrayScottFingerPrintsPresets.all;

  @override
  List<F0737GrayScottFingerPrintsVariant> get variants => F0737GrayScottFingerPrintsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
