// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0600_tetrahedral_sierpinski_scaled_presets.dart';
import 'f0600_tetrahedral_sierpinski_scaled_variants.dart';
import 'f0600_tetrahedral_sierpinski_scaled_metadata.dart';

/// Tetrahedral Sierpinski (scaled) — 3D Raymarching & Hypercomplex.
class F0600TetrahedralSierpinskiScaled extends Raymarched3DModule {
  F0600TetrahedralSierpinskiScaled()
      : super(
          id: 'f0600_tetrahedral_sierpinski_scaled',
          shader: 'shaders/f0600_tetrahedral_sierpinski_scaled_gpu.frag',
        );

  @override
  F0600TetrahedralSierpinskiScaledMetadata get metadata => F0600TetrahedralSierpinskiScaledMetadata.instance;

  @override
  List<F0600TetrahedralSierpinskiScaledPreset> get presets => F0600TetrahedralSierpinskiScaledPresets.all;

  @override
  List<F0600TetrahedralSierpinskiScaledVariant> get variants => F0600TetrahedralSierpinskiScaledVariants.all;

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
