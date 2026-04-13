// Base class for strange attractors (Lorenz, Rössler, Chen, Lü, etc.).
import 'package:meta/meta.dart';
import 'shader_params.dart';

@immutable
abstract class AttractorModule {
  final String id;
  final String shader;

  const AttractorModule({
    required this.id,
    required this.shader,
  });

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;

  int get defaultIterations => 100000;
  double get defaultStepSize => 0.01;

  void configureShader(ShaderParams p);
}
