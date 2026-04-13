// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0597_sierpinski_carpet_3d_menger_cross_presets.dart';
import 'f0597_sierpinski_carpet_3d_menger_cross_variants.dart';
import 'f0597_sierpinski_carpet_3d_menger_cross_metadata.dart';

/// Sierpinski Carpet 3D (Menger cross) — 3D Raymarching & Hypercomplex.
class F0597SierpinskiCarpet3dMengerCross extends Raymarched3DModule {
  F0597SierpinskiCarpet3dMengerCross()
      : super(
          id: 'f0597_sierpinski_carpet_3d_menger_cross',
          shader: 'shaders/f0597_sierpinski_carpet_3d_menger_cross_gpu.frag',
        );

  @override
  F0597SierpinskiCarpet3dMengerCrossMetadata get metadata => F0597SierpinskiCarpet3dMengerCrossMetadata.instance;

  @override
  List<F0597SierpinskiCarpet3dMengerCrossPreset> get presets => F0597SierpinskiCarpet3dMengerCrossPresets.all;

  @override
  List<F0597SierpinskiCarpet3dMengerCrossVariant> get variants => F0597SierpinskiCarpet3dMengerCrossVariants.all;

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
