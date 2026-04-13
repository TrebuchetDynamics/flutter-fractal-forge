// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0584_amazing_box_compact_presets.dart';
import 'f0584_amazing_box_compact_variants.dart';
import 'f0584_amazing_box_compact_metadata.dart';

/// Amazing Box (compact) — 3D Raymarching & Hypercomplex.
class F0584AmazingBoxCompact extends Raymarched3DModule {
  F0584AmazingBoxCompact()
      : super(
          id: 'f0584_amazing_box_compact',
          shader: 'shaders/f0584_amazing_box_compact_gpu.frag',
        );

  @override
  F0584AmazingBoxCompactMetadata get metadata => F0584AmazingBoxCompactMetadata.instance;

  @override
  List<F0584AmazingBoxCompactPreset> get presets => F0584AmazingBoxCompactPresets.all;

  @override
  List<F0584AmazingBoxCompactVariant> get variants => F0584AmazingBoxCompactVariants.all;

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
