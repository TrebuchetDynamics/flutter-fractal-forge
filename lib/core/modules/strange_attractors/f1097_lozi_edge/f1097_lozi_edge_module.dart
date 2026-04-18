// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1097_lozi_edge_presets.dart';
import 'f1097_lozi_edge_variants.dart';
import 'f1097_lozi_edge_metadata.dart';

/// Lozi Edge — Strange Attractors.
class F1097LoziEdge extends AttractorModule {
  F1097LoziEdge()
      : super(
          id: 'f1097_lozi_edge',
          shader: 'shaders/f1097_lozi_edge_gpu.frag',
        );

  @override
  F1097LoziEdgeMetadata get metadata => F1097LoziEdgeMetadata.instance;

  @override
  List<F1097LoziEdgePreset> get presets => F1097LoziEdgePresets.all;

  @override
  List<F1097LoziEdgeVariant> get variants => F1097LoziEdgeVariants.all;

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
