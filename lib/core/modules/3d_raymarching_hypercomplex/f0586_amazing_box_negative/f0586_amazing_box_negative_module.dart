// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0586_amazing_box_negative_presets.dart';
import 'f0586_amazing_box_negative_variants.dart';
import 'f0586_amazing_box_negative_metadata.dart';

/// Amazing Box (negative) — 3D Raymarching & Hypercomplex.
class F0586AmazingBoxNegative extends Raymarched3DModule {
  F0586AmazingBoxNegative()
      : super(
          id: 'f0586_amazing_box_negative',
          shader: 'shaders/f0586_amazing_box_negative_gpu.frag',
        );

  @override
  F0586AmazingBoxNegativeMetadata get metadata => F0586AmazingBoxNegativeMetadata.instance;

  @override
  List<F0586AmazingBoxNegativePreset> get presets => F0586AmazingBoxNegativePresets.all;

  @override
  List<F0586AmazingBoxNegativeVariant> get variants => F0586AmazingBoxNegativeVariants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
