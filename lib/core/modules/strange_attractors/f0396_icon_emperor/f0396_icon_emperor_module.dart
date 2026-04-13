// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0396_icon_emperor_presets.dart';
import 'f0396_icon_emperor_variants.dart';
import 'f0396_icon_emperor_metadata.dart';

/// Icon — Emperor — Strange Attractors.
class F0396IconEmperor extends AttractorModule {
  F0396IconEmperor()
      : super(
          id: 'f0396_icon_emperor',
          shader: 'shaders/f0396_icon_emperor_gpu.frag',
        );

  @override
  F0396IconEmperorMetadata get metadata => F0396IconEmperorMetadata.instance;

  @override
  List<F0396IconEmperorPreset> get presets => F0396IconEmperorPresets.all;

  @override
  List<F0396IconEmperorVariant> get variants => F0396IconEmperorVariants.all;

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
