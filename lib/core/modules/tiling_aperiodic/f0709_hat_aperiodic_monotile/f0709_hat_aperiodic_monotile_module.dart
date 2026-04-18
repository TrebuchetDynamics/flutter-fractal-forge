// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0709_hat_aperiodic_monotile_presets.dart';
import 'f0709_hat_aperiodic_monotile_variants.dart';
import 'f0709_hat_aperiodic_monotile_metadata.dart';

/// Hat Aperiodic Monotile — Tiling & Aperiodic.
class F0709HatAperiodicMonotile extends IFSModule {
  F0709HatAperiodicMonotile()
      : super(
          id: 'f0709_hat_aperiodic_monotile',
          shader: 'shaders/f0709_hat_aperiodic_monotile_gpu.frag',
        );

  @override
  F0709HatAperiodicMonotileMetadata get metadata => F0709HatAperiodicMonotileMetadata.instance;

  @override
  List<F0709HatAperiodicMonotilePreset> get presets => F0709HatAperiodicMonotilePresets.all;

  @override
  List<F0709HatAperiodicMonotileVariant> get variants => F0709HatAperiodicMonotileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
