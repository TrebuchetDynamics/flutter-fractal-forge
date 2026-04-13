// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0476_triple_antenna_point_presets.dart';
import 'f0476_triple_antenna_point_variants.dart';
import 'f0476_triple_antenna_point_metadata.dart';

/// Triple Antenna Point — Escape-Time (Complex Plane).
class F0476TripleAntennaPoint extends EscapeTimeModule {
  F0476TripleAntennaPoint()
      : super(
          id: 'f0476_triple_antenna_point',
          shader: 'shaders/f0476_triple_antenna_point_gpu.frag',
        );

  @override
  F0476TripleAntennaPointMetadata get metadata => F0476TripleAntennaPointMetadata.instance;

  @override
  List<F0476TripleAntennaPointPreset> get presets => F0476TripleAntennaPointPresets.all;

  @override
  List<F0476TripleAntennaPointVariant> get variants => F0476TripleAntennaPointVariants.all;

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
