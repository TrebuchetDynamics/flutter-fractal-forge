// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0835_moore_curve_closed_hilbert_presets.dart';
import 'f0835_moore_curve_closed_hilbert_variants.dart';
import 'f0835_moore_curve_closed_hilbert_metadata.dart';

/// Moore Curve (Closed Hilbert) — L-Systems & Space-Filling.
class F0835MooreCurveClosedHilbert extends LSystemModule {
  F0835MooreCurveClosedHilbert()
      : super(
          id: 'f0835_moore_curve_closed_hilbert',
          shader: 'shaders/f0835_moore_curve_closed_hilbert_gpu.frag',
        );

  @override
  F0835MooreCurveClosedHilbertMetadata get metadata => F0835MooreCurveClosedHilbertMetadata.instance;

  @override
  List<F0835MooreCurveClosedHilbertPreset> get presets => F0835MooreCurveClosedHilbertPresets.all;

  @override
  List<F0835MooreCurveClosedHilbertVariant> get variants => F0835MooreCurveClosedHilbertVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
