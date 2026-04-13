// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0456_period_3_bulb_center_presets.dart';
import 'f0456_period_3_bulb_center_variants.dart';
import 'f0456_period_3_bulb_center_metadata.dart';

/// Period-3 Bulb Center — Escape-Time (Complex Plane).
class F0456Period3BulbCenter extends EscapeTimeModule {
  F0456Period3BulbCenter()
      : super(
          id: 'f0456_period_3_bulb_center',
          shader: 'shaders/f0456_period_3_bulb_center_gpu.frag',
        );

  @override
  F0456Period3BulbCenterMetadata get metadata => F0456Period3BulbCenterMetadata.instance;

  @override
  List<F0456Period3BulbCenterPreset> get presets => F0456Period3BulbCenterPresets.all;

  @override
  List<F0456Period3BulbCenterVariant> get variants => F0456Period3BulbCenterVariants.all;

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
