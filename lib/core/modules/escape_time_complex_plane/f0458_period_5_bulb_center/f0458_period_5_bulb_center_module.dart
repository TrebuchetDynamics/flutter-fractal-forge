// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0458_period_5_bulb_center_presets.dart';
import 'f0458_period_5_bulb_center_variants.dart';
import 'f0458_period_5_bulb_center_metadata.dart';

/// Period-5 Bulb Center — Escape-Time (Complex Plane).
class F0458Period5BulbCenter extends EscapeTimeModule {
  F0458Period5BulbCenter()
      : super(
          id: 'f0458_period_5_bulb_center',
          shader: 'shaders/f0458_period_5_bulb_center_gpu.frag',
        );

  @override
  F0458Period5BulbCenterMetadata get metadata => F0458Period5BulbCenterMetadata.instance;

  @override
  List<F0458Period5BulbCenterPreset> get presets => F0458Period5BulbCenterPresets.all;

  @override
  List<F0458Period5BulbCenterVariant> get variants => F0458Period5BulbCenterVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
