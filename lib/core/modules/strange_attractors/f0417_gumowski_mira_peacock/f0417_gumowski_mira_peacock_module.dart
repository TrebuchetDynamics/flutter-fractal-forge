// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0417_gumowski_mira_peacock_presets.dart';
import 'f0417_gumowski_mira_peacock_variants.dart';
import 'f0417_gumowski_mira_peacock_metadata.dart';

/// Gumowski-Mira Peacock — Strange Attractors.
class F0417GumowskiMiraPeacock extends AttractorModule {
  F0417GumowskiMiraPeacock()
      : super(
          id: 'f0417_gumowski_mira_peacock',
          shader: 'shaders/f0417_gumowski_mira_peacock_gpu.frag',
        );

  @override
  F0417GumowskiMiraPeacockMetadata get metadata => F0417GumowskiMiraPeacockMetadata.instance;

  @override
  List<F0417GumowskiMiraPeacockPreset> get presets => F0417GumowskiMiraPeacockPresets.all;

  @override
  List<F0417GumowskiMiraPeacockVariant> get variants => F0417GumowskiMiraPeacockVariants.all;

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
