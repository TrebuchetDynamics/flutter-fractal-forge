// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0469_bulbous_valley_presets.dart';
import 'f0469_bulbous_valley_variants.dart';
import 'f0469_bulbous_valley_metadata.dart';

/// Bulbous Valley — Escape-Time (Complex Plane).
class F0469BulbousValley extends EscapeTimeModule {
  F0469BulbousValley()
      : super(
          id: 'f0469_bulbous_valley',
          shader: 'shaders/f0469_bulbous_valley_gpu.frag',
        );

  @override
  F0469BulbousValleyMetadata get metadata => F0469BulbousValleyMetadata.instance;

  @override
  List<F0469BulbousValleyPreset> get presets => F0469BulbousValleyPresets.all;

  @override
  List<F0469BulbousValleyVariant> get variants => F0469BulbousValleyVariants.all;

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
