// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0608_lyapunov_bbaba_presets.dart';
import 'f0608_lyapunov_bbaba_variants.dart';
import 'f0608_lyapunov_bbaba_metadata.dart';

/// Lyapunov BBABA — Lyapunov & Stability.
class F0608LyapunovBbaba extends EscapeTimeModule {
  F0608LyapunovBbaba()
      : super(
          id: 'f0608_lyapunov_bbaba',
          shader: 'shaders/f0608_lyapunov_bbaba_gpu.frag',
        );

  @override
  F0608LyapunovBbabaMetadata get metadata => F0608LyapunovBbabaMetadata.instance;

  @override
  List<F0608LyapunovBbabaPreset> get presets => F0608LyapunovBbabaPresets.all;

  @override
  List<F0608LyapunovBbabaVariant> get variants => F0608LyapunovBbabaVariants.all;

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
