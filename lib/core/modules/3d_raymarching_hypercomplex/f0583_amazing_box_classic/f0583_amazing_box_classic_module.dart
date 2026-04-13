// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0583_amazing_box_classic_presets.dart';
import 'f0583_amazing_box_classic_variants.dart';
import 'f0583_amazing_box_classic_metadata.dart';

/// Amazing Box (classic) — 3D Raymarching & Hypercomplex.
class F0583AmazingBoxClassic extends Raymarched3DModule {
  F0583AmazingBoxClassic()
      : super(
          id: 'f0583_amazing_box_classic',
          shader: 'shaders/f0583_amazing_box_classic_gpu.frag',
        );

  @override
  F0583AmazingBoxClassicMetadata get metadata => F0583AmazingBoxClassicMetadata.instance;

  @override
  List<F0583AmazingBoxClassicPreset> get presets => F0583AmazingBoxClassicPresets.all;

  @override
  List<F0583AmazingBoxClassicVariant> get variants => F0583AmazingBoxClassicVariants.all;

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
