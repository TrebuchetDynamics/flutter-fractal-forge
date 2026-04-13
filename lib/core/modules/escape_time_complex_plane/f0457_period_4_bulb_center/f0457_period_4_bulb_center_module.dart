// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0457_period_4_bulb_center_presets.dart';
import 'f0457_period_4_bulb_center_variants.dart';
import 'f0457_period_4_bulb_center_metadata.dart';

/// Period-4 Bulb Center — Escape-Time (Complex Plane).
class F0457Period4BulbCenter extends EscapeTimeModule {
  F0457Period4BulbCenter()
      : super(
          id: 'f0457_period_4_bulb_center',
          shader: 'shaders/f0457_period_4_bulb_center_gpu.frag',
        );

  @override
  F0457Period4BulbCenterMetadata get metadata => F0457Period4BulbCenterMetadata.instance;

  @override
  List<F0457Period4BulbCenterPreset> get presets => F0457Period4BulbCenterPresets.all;

  @override
  List<F0457Period4BulbCenterVariant> get variants => F0457Period4BulbCenterVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 800;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
