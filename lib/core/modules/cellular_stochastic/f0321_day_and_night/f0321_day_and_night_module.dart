// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0321_day_and_night_presets.dart';
import 'f0321_day_and_night_variants.dart';
import 'f0321_day_and_night_metadata.dart';

/// Day and Night — Cellular & Stochastic.
class F0321DayAndNight extends CellularModule {
  F0321DayAndNight()
      : super(
          id: 'f0321_day_and_night',
          shader: 'shaders/f0321_day_and_night_gpu.frag',
        );

  @override
  F0321DayAndNightMetadata get metadata => F0321DayAndNightMetadata.instance;

  @override
  List<F0321DayAndNightPreset> get presets => F0321DayAndNightPresets.all;

  @override
  List<F0321DayAndNightVariant> get variants => F0321DayAndNightVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
