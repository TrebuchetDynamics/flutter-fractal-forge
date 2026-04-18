// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1130_fractal_flame_v29_cylinder_presets.dart';
import 'f1130_fractal_flame_v29_cylinder_variants.dart';
import 'f1130_fractal_flame_v29_cylinder_metadata.dart';

/// Fractal Flame V29 Cylinder — IFS & Geometric Construction.
class F1130FractalFlameV29Cylinder extends IFSModule {
  F1130FractalFlameV29Cylinder()
      : super(
          id: 'f1130_fractal_flame_v29_cylinder',
          shader: 'shaders/f1130_fractal_flame_v29_cylinder_gpu.frag',
        );

  @override
  F1130FractalFlameV29CylinderMetadata get metadata => F1130FractalFlameV29CylinderMetadata.instance;

  @override
  List<F1130FractalFlameV29CylinderPreset> get presets => F1130FractalFlameV29CylinderPresets.all;

  @override
  List<F1130FractalFlameV29CylinderVariant> get variants => F1130FractalFlameV29CylinderVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
