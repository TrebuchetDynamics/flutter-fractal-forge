// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1092_zaslavsky_wide_presets.dart';
import 'f1092_zaslavsky_wide_variants.dart';
import 'f1092_zaslavsky_wide_metadata.dart';

/// Zaslavsky Wide — Strange Attractors.
class F1092ZaslavskyWide extends AttractorModule {
  F1092ZaslavskyWide()
      : super(
          id: 'f1092_zaslavsky_wide',
          shader: 'shaders/f1092_zaslavsky_wide_gpu.frag',
        );

  @override
  F1092ZaslavskyWideMetadata get metadata => F1092ZaslavskyWideMetadata.instance;

  @override
  List<F1092ZaslavskyWidePreset> get presets => F1092ZaslavskyWidePresets.all;

  @override
  List<F1092ZaslavskyWideVariant> get variants => F1092ZaslavskyWideVariants.all;

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
