// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1094_zaslavsky_edge_presets.dart';
import 'f1094_zaslavsky_edge_variants.dart';
import 'f1094_zaslavsky_edge_metadata.dart';

/// Zaslavsky Edge — Strange Attractors.
class F1094ZaslavskyEdge extends AttractorModule {
  F1094ZaslavskyEdge()
      : super(
          id: 'f1094_zaslavsky_edge',
          shader: 'shaders/f1094_zaslavsky_edge_gpu.frag',
        );

  @override
  F1094ZaslavskyEdgeMetadata get metadata => F1094ZaslavskyEdgeMetadata.instance;

  @override
  List<F1094ZaslavskyEdgePreset> get presets => F1094ZaslavskyEdgePresets.all;

  @override
  List<F1094ZaslavskyEdgeVariant> get variants => F1094ZaslavskyEdgeVariants.all;

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
