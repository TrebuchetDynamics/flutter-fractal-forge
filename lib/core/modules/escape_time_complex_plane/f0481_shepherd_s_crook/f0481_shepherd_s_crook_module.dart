// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0481_shepherd_s_crook_presets.dart';
import 'f0481_shepherd_s_crook_variants.dart';
import 'f0481_shepherd_s_crook_metadata.dart';

/// Shepherd's Crook — Escape-Time (Complex Plane).
class F0481ShepherdSCrook extends EscapeTimeModule {
  F0481ShepherdSCrook()
      : super(
          id: 'f0481_shepherd_s_crook',
          shader: 'shaders/f0481_shepherd_s_crook_gpu.frag',
        );

  @override
  F0481ShepherdSCrookMetadata get metadata => F0481ShepherdSCrookMetadata.instance;

  @override
  List<F0481ShepherdSCrookPreset> get presets => F0481ShepherdSCrookPresets.all;

  @override
  List<F0481ShepherdSCrookVariant> get variants => F0481ShepherdSCrookVariants.all;

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
