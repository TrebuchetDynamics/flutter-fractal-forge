// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0374_de_jong_flow_presets.dart';
import 'f0374_de_jong_flow_variants.dart';
import 'f0374_de_jong_flow_metadata.dart';

/// de Jong Flow — Strange Attractors.
class F0374DeJongFlow extends AttractorModule {
  F0374DeJongFlow()
      : super(
          id: 'f0374_de_jong_flow',
          shader: 'shaders/f0374_de_jong_flow_gpu.frag',
        );

  @override
  F0374DeJongFlowMetadata get metadata => F0374DeJongFlowMetadata.instance;

  @override
  List<F0374DeJongFlowPreset> get presets => F0374DeJongFlowPresets.all;

  @override
  List<F0374DeJongFlowVariant> get variants => F0374DeJongFlowVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
