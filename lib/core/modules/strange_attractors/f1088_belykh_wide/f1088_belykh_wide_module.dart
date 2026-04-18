// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1088_belykh_wide_presets.dart';
import 'f1088_belykh_wide_variants.dart';
import 'f1088_belykh_wide_metadata.dart';

/// Belykh Wide — Strange Attractors.
class F1088BelykhWide extends AttractorModule {
  F1088BelykhWide()
      : super(
          id: 'f1088_belykh_wide',
          shader: 'shaders/f1088_belykh_wide_gpu.frag',
        );

  @override
  F1088BelykhWideMetadata get metadata => F1088BelykhWideMetadata.instance;

  @override
  List<F1088BelykhWidePreset> get presets => F1088BelykhWidePresets.all;

  @override
  List<F1088BelykhWideVariant> get variants => F1088BelykhWideVariants.all;

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
