// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0364_clifford_scroll_presets.dart';
import 'f0364_clifford_scroll_variants.dart';
import 'f0364_clifford_scroll_metadata.dart';

/// Clifford Scroll — Strange Attractors.
class F0364CliffordScroll extends AttractorModule {
  F0364CliffordScroll()
      : super(
          id: 'f0364_clifford_scroll',
          shader: 'shaders/f0364_clifford_scroll_gpu.frag',
        );

  @override
  F0364CliffordScrollMetadata get metadata => F0364CliffordScrollMetadata.instance;

  @override
  List<F0364CliffordScrollPreset> get presets => F0364CliffordScrollPresets.all;

  @override
  List<F0364CliffordScrollVariant> get variants => F0364CliffordScrollVariants.all;

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
