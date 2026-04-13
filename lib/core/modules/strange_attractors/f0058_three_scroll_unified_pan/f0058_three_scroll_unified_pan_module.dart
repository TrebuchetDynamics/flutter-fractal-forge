// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0058_three_scroll_unified_pan_presets.dart';
import 'f0058_three_scroll_unified_pan_variants.dart';
import 'f0058_three_scroll_unified_pan_metadata.dart';

/// Three-Scroll Unified (Pan) — Strange Attractors.
class F0058ThreeScrollUnifiedPan extends AttractorModule {
  F0058ThreeScrollUnifiedPan()
      : super(
          id: 'f0058_three_scroll_unified_pan',
          shader: 'shaders/f0058_three_scroll_unified_pan_gpu.frag',
        );

  @override
  F0058ThreeScrollUnifiedPanMetadata get metadata => F0058ThreeScrollUnifiedPanMetadata.instance;

  @override
  List<F0058ThreeScrollUnifiedPanPreset> get presets => F0058ThreeScrollUnifiedPanPresets.all;

  @override
  List<F0058ThreeScrollUnifiedPanVariant> get variants => F0058ThreeScrollUnifiedPanVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
