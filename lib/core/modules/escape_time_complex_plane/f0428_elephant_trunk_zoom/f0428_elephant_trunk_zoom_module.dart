// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0428_elephant_trunk_zoom_presets.dart';
import 'f0428_elephant_trunk_zoom_variants.dart';
import 'f0428_elephant_trunk_zoom_metadata.dart';

/// Elephant Trunk Zoom — Escape-Time (Complex Plane).
class F0428ElephantTrunkZoom extends EscapeTimeModule {
  F0428ElephantTrunkZoom()
      : super(
          id: 'f0428_elephant_trunk_zoom',
          shader: 'shaders/f0428_elephant_trunk_zoom_gpu.frag',
        );

  @override
  F0428ElephantTrunkZoomMetadata get metadata => F0428ElephantTrunkZoomMetadata.instance;

  @override
  List<F0428ElephantTrunkZoomPreset> get presets => F0428ElephantTrunkZoomPresets.all;

  @override
  List<F0428ElephantTrunkZoomVariant> get variants => F0428ElephantTrunkZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
