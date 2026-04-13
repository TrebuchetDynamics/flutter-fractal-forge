// Base class for cellular automaton / stochastic fractals.
import 'package:meta/meta.dart';
import 'shader_params.dart';

@immutable
abstract class CellularModule {
  final String id;
  final String shader;

  const CellularModule({
    required this.id,
    required this.shader,
  });

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;

  int get defaultGenerations => 100;

  void configureShader(ShaderParams p);
}
