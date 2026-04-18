// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1228_shishikura_map_presets.dart';
import 'f1228_shishikura_map_variants.dart';
import 'f1228_shishikura_map_metadata.dart';

/// Shishikura Map — Escape-Time (Complex Plane).
class F1228ShishikuraMap extends EscapeTimeModule {
  F1228ShishikuraMap()
      : super(
          id: 'f1228_shishikura_map',
          shader: 'shaders/f1228_shishikura_map_gpu.frag',
        );

  @override
  F1228ShishikuraMapMetadata get metadata => F1228ShishikuraMapMetadata.instance;

  @override
  List<F1228ShishikuraMapPreset> get presets => F1228ShishikuraMapPresets.all;

  @override
  List<F1228ShishikuraMapVariant> get variants => F1228ShishikuraMapVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

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
