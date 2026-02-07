import 'package:vector_math/vector_math.dart';

class FractalViewState {
  final Vector2 pan;
  final double zoom;
  final Vector3 rotation;

  const FractalViewState({
    required this.pan,
    required this.zoom,
    required this.rotation,
  });

  FractalViewState.initial()
      : pan = Vector2.zero(),
        zoom = 1.0,
        rotation = Vector3.zero();

  FractalViewState copyWith({
    Vector2? pan,
    double? zoom,
    Vector3? rotation,
  }) {
    return FractalViewState(
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
    );
  }
}
