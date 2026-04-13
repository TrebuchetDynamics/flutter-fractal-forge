// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0455_period_2_bulb_center_presets.dart';
import 'f0455_period_2_bulb_center_variants.dart';
import 'f0455_period_2_bulb_center_metadata.dart';

/// Period-2 Bulb Center — Escape-Time (Complex Plane).
class F0455Period2BulbCenter extends EscapeTimeModule {
  F0455Period2BulbCenter()
      : super(
          id: 'f0455_period_2_bulb_center',
          shader: 'shaders/f0455_period_2_bulb_center_gpu.frag',
        );

  @override
  F0455Period2BulbCenterMetadata get metadata => F0455Period2BulbCenterMetadata.instance;

  @override
  List<F0455Period2BulbCenterPreset> get presets => F0455Period2BulbCenterPresets.all;

  @override
  List<F0455Period2BulbCenterVariant> get variants => F0455Period2BulbCenterVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
