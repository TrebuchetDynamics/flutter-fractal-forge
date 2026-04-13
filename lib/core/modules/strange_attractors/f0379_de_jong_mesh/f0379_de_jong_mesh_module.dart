// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0379_de_jong_mesh_presets.dart';
import 'f0379_de_jong_mesh_variants.dart';
import 'f0379_de_jong_mesh_metadata.dart';

/// de Jong Mesh — Strange Attractors.
class F0379DeJongMesh extends AttractorModule {
  F0379DeJongMesh()
      : super(
          id: 'f0379_de_jong_mesh',
          shader: 'shaders/f0379_de_jong_mesh_gpu.frag',
        );

  @override
  F0379DeJongMeshMetadata get metadata => F0379DeJongMeshMetadata.instance;

  @override
  List<F0379DeJongMeshPreset> get presets => F0379DeJongMeshPresets.all;

  @override
  List<F0379DeJongMeshVariant> get variants => F0379DeJongMeshVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
