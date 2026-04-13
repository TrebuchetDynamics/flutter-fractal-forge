// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0635_lyapunov_abbaba_presets.dart';
import 'f0635_lyapunov_abbaba_variants.dart';
import 'f0635_lyapunov_abbaba_metadata.dart';

/// Lyapunov ABBABA — Lyapunov & Stability.
class F0635LyapunovAbbaba extends EscapeTimeModule {
  F0635LyapunovAbbaba()
      : super(
          id: 'f0635_lyapunov_abbaba',
          shader: 'shaders/f0635_lyapunov_abbaba_gpu.frag',
        );

  @override
  F0635LyapunovAbbabaMetadata get metadata => F0635LyapunovAbbabaMetadata.instance;

  @override
  List<F0635LyapunovAbbabaPreset> get presets => F0635LyapunovAbbabaPresets.all;

  @override
  List<F0635LyapunovAbbabaVariant> get variants => F0635LyapunovAbbabaVariants.all;

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
