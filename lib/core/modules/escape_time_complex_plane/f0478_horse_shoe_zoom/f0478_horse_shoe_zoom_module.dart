// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0478_horse_shoe_zoom_presets.dart';
import 'f0478_horse_shoe_zoom_variants.dart';
import 'f0478_horse_shoe_zoom_metadata.dart';

/// Horse-Shoe Zoom — Escape-Time (Complex Plane).
class F0478HorseShoeZoom extends EscapeTimeModule {
  F0478HorseShoeZoom()
      : super(
          id: 'f0478_horse_shoe_zoom',
          shader: 'shaders/f0478_horse_shoe_zoom_gpu.frag',
        );

  @override
  F0478HorseShoeZoomMetadata get metadata => F0478HorseShoeZoomMetadata.instance;

  @override
  List<F0478HorseShoeZoomPreset> get presets => F0478HorseShoeZoomPresets.all;

  @override
  List<F0478HorseShoeZoomVariant> get variants => F0478HorseShoeZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
