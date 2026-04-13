// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0395_icon_trampoline_presets.dart';
import 'f0395_icon_trampoline_variants.dart';
import 'f0395_icon_trampoline_metadata.dart';

/// Icon — Trampoline — Strange Attractors.
class F0395IconTrampoline extends AttractorModule {
  F0395IconTrampoline()
      : super(
          id: 'f0395_icon_trampoline',
          shader: 'shaders/f0395_icon_trampoline_gpu.frag',
        );

  @override
  F0395IconTrampolineMetadata get metadata => F0395IconTrampolineMetadata.instance;

  @override
  List<F0395IconTrampolinePreset> get presets => F0395IconTrampolinePresets.all;

  @override
  List<F0395IconTrampolineVariant> get variants => F0395IconTrampolineVariants.all;

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
