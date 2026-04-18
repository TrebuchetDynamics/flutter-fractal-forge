// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0691_pinwheel_tiling_presets.dart';
import 'f0691_pinwheel_tiling_variants.dart';
import 'f0691_pinwheel_tiling_metadata.dart';

/// Pinwheel Tiling — Tiling & Aperiodic.
class F0691PinwheelTiling extends IFSModule {
  F0691PinwheelTiling()
      : super(
          id: 'f0691_pinwheel_tiling',
          shader: 'shaders/f0691_pinwheel_tiling_gpu.frag',
        );

  @override
  F0691PinwheelTilingMetadata get metadata => F0691PinwheelTilingMetadata.instance;

  @override
  List<F0691PinwheelTilingPreset> get presets => F0691PinwheelTilingPresets.all;

  @override
  List<F0691PinwheelTilingVariant> get variants => F0691PinwheelTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
