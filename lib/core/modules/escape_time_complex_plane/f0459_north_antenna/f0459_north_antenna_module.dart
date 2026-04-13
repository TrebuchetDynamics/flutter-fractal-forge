// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0459_north_antenna_presets.dart';
import 'f0459_north_antenna_variants.dart';
import 'f0459_north_antenna_metadata.dart';

/// North Antenna — Escape-Time (Complex Plane).
class F0459NorthAntenna extends EscapeTimeModule {
  F0459NorthAntenna()
      : super(
          id: 'f0459_north_antenna',
          shader: 'shaders/f0459_north_antenna_gpu.frag',
        );

  @override
  F0459NorthAntennaMetadata get metadata => F0459NorthAntennaMetadata.instance;

  @override
  List<F0459NorthAntennaPreset> get presets => F0459NorthAntennaPresets.all;

  @override
  List<F0459NorthAntennaVariant> get variants => F0459NorthAntennaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 400;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
