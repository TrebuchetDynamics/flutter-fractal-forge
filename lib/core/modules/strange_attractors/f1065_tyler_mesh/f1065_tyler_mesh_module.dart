// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1065_tyler_mesh_presets.dart';
import 'f1065_tyler_mesh_variants.dart';
import 'f1065_tyler_mesh_metadata.dart';

/// Tyler Mesh — Strange Attractors.
class F1065TylerMesh extends AttractorModule {
  F1065TylerMesh()
      : super(
          id: 'f1065_tyler_mesh',
          shader: 'shaders/f1065_tyler_mesh_gpu.frag',
        );

  @override
  F1065TylerMeshMetadata get metadata => F1065TylerMeshMetadata.instance;

  @override
  List<F1065TylerMeshPreset> get presets => F1065TylerMeshPresets.all;

  @override
  List<F1065TylerMeshVariant> get variants => F1065TylerMeshVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
