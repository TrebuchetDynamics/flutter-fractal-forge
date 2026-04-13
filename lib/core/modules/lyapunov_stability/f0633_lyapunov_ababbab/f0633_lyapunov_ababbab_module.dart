// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0633_lyapunov_ababbab_presets.dart';
import 'f0633_lyapunov_ababbab_variants.dart';
import 'f0633_lyapunov_ababbab_metadata.dart';

/// Lyapunov ABABBAB — Lyapunov & Stability.
class F0633LyapunovAbabbab extends EscapeTimeModule {
  F0633LyapunovAbabbab()
      : super(
          id: 'f0633_lyapunov_ababbab',
          shader: 'shaders/f0633_lyapunov_ababbab_gpu.frag',
        );

  @override
  F0633LyapunovAbabbabMetadata get metadata => F0633LyapunovAbabbabMetadata.instance;

  @override
  List<F0633LyapunovAbabbabPreset> get presets => F0633LyapunovAbabbabPresets.all;

  @override
  List<F0633LyapunovAbabbabVariant> get variants => F0633LyapunovAbabbabVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 300;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
