// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0585_amazing_box_open_presets.dart';
import 'f0585_amazing_box_open_variants.dart';
import 'f0585_amazing_box_open_metadata.dart';

/// Amazing Box (open) — 3D Raymarching & Hypercomplex.
class F0585AmazingBoxOpen extends Raymarched3DModule {
  F0585AmazingBoxOpen()
      : super(
          id: 'f0585_amazing_box_open',
          shader: 'shaders/f0585_amazing_box_open_gpu.frag',
        );

  @override
  F0585AmazingBoxOpenMetadata get metadata => F0585AmazingBoxOpenMetadata.instance;

  @override
  List<F0585AmazingBoxOpenPreset> get presets => F0585AmazingBoxOpenPresets.all;

  @override
  List<F0585AmazingBoxOpenVariant> get variants => F0585AmazingBoxOpenVariants.all;

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
