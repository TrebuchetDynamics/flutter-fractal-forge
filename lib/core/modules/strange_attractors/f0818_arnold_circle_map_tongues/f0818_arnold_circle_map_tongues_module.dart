// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0818_arnold_circle_map_tongues_presets.dart';
import 'f0818_arnold_circle_map_tongues_variants.dart';
import 'f0818_arnold_circle_map_tongues_metadata.dart';

/// Arnold Circle Map (Tongues) — Strange Attractors.
class F0818ArnoldCircleMapTongues extends AttractorModule {
  F0818ArnoldCircleMapTongues()
      : super(
          id: 'f0818_arnold_circle_map_tongues',
          shader: 'shaders/f0818_arnold_circle_map_tongues_gpu.frag',
        );

  @override
  F0818ArnoldCircleMapTonguesMetadata get metadata => F0818ArnoldCircleMapTonguesMetadata.instance;

  @override
  List<F0818ArnoldCircleMapTonguesPreset> get presets => F0818ArnoldCircleMapTonguesPresets.all;

  @override
  List<F0818ArnoldCircleMapTonguesVariant> get variants => F0818ArnoldCircleMapTonguesVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
