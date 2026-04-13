// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0128_cauliflower_period_3_bulb_presets.dart';
import 'f0128_cauliflower_period_3_bulb_variants.dart';
import 'f0128_cauliflower_period_3_bulb_metadata.dart';

/// Cauliflower (period-3 bulb) — Escape-Time (Complex Plane).
class F0128CauliflowerPeriod3Bulb extends EscapeTimeModule {
  F0128CauliflowerPeriod3Bulb()
      : super(
          id: 'f0128_cauliflower_period_3_bulb',
          shader: 'shaders/f0128_cauliflower_period_3_bulb_gpu.frag',
        );

  @override
  F0128CauliflowerPeriod3BulbMetadata get metadata => F0128CauliflowerPeriod3BulbMetadata.instance;

  @override
  List<F0128CauliflowerPeriod3BulbPreset> get presets => F0128CauliflowerPeriod3BulbPresets.all;

  @override
  List<F0128CauliflowerPeriod3BulbVariant> get variants => F0128CauliflowerPeriod3BulbVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
