// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1093_zaslavsky_tight_presets.dart';
import 'f1093_zaslavsky_tight_variants.dart';
import 'f1093_zaslavsky_tight_metadata.dart';

/// Zaslavsky Tight — Strange Attractors.
class F1093ZaslavskyTight extends AttractorModule {
  F1093ZaslavskyTight()
      : super(
          id: 'f1093_zaslavsky_tight',
          shader: 'shaders/f1093_zaslavsky_tight_gpu.frag',
        );

  @override
  F1093ZaslavskyTightMetadata get metadata => F1093ZaslavskyTightMetadata.instance;

  @override
  List<F1093ZaslavskyTightPreset> get presets => F1093ZaslavskyTightPresets.all;

  @override
  List<F1093ZaslavskyTightVariant> get variants => F1093ZaslavskyTightVariants.all;

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
