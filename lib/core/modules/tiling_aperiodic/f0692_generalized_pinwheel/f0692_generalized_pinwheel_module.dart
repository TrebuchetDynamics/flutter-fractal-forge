// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0692_generalized_pinwheel_presets.dart';
import 'f0692_generalized_pinwheel_variants.dart';
import 'f0692_generalized_pinwheel_metadata.dart';

/// Generalized Pinwheel — Tiling & Aperiodic.
class F0692GeneralizedPinwheel extends IFSModule {
  F0692GeneralizedPinwheel()
      : super(
          id: 'f0692_generalized_pinwheel',
          shader: 'shaders/f0692_generalized_pinwheel_gpu.frag',
        );

  @override
  F0692GeneralizedPinwheelMetadata get metadata => F0692GeneralizedPinwheelMetadata.instance;

  @override
  List<F0692GeneralizedPinwheelPreset> get presets => F0692GeneralizedPinwheelPresets.all;

  @override
  List<F0692GeneralizedPinwheelVariant> get variants => F0692GeneralizedPinwheelVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
