// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1227_herman_ring_map_presets.dart';
import 'f1227_herman_ring_map_variants.dart';
import 'f1227_herman_ring_map_metadata.dart';

/// Herman Ring Map — Escape-Time (Complex Plane).
class F1227HermanRingMap extends EscapeTimeModule {
  F1227HermanRingMap()
      : super(
          id: 'f1227_herman_ring_map',
          shader: 'shaders/f1227_herman_ring_map_gpu.frag',
        );

  @override
  F1227HermanRingMapMetadata get metadata => F1227HermanRingMapMetadata.instance;

  @override
  List<F1227HermanRingMapPreset> get presets => F1227HermanRingMapPresets.all;

  @override
  List<F1227HermanRingMapVariant> get variants => F1227HermanRingMapVariants.all;

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
