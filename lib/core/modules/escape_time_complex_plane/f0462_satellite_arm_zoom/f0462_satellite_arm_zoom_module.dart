// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0462_satellite_arm_zoom_presets.dart';
import 'f0462_satellite_arm_zoom_variants.dart';
import 'f0462_satellite_arm_zoom_metadata.dart';

/// Satellite Arm Zoom — Escape-Time (Complex Plane).
class F0462SatelliteArmZoom extends EscapeTimeModule {
  F0462SatelliteArmZoom()
      : super(
          id: 'f0462_satellite_arm_zoom',
          shader: 'shaders/f0462_satellite_arm_zoom_gpu.frag',
        );

  @override
  F0462SatelliteArmZoomMetadata get metadata => F0462SatelliteArmZoomMetadata.instance;

  @override
  List<F0462SatelliteArmZoomPreset> get presets => F0462SatelliteArmZoomPresets.all;

  @override
  List<F0462SatelliteArmZoomVariant> get variants => F0462SatelliteArmZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
