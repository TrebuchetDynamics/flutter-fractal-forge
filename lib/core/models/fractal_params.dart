import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math.dart';

class FractalParams extends Equatable {
  final double power;
  final int iterations;
  final double bailout;
  final double zoom;
  final Vector3 rotation;
  final int colorScheme;
  final Vector2 mousePos;
  final FractalType fractalType;
  
  const FractalParams({
    this.power = 8.0,
    this.iterations = 50,
    this.bailout = 2.0,
    this.zoom = 1.0,
    required this.rotation,
    this.colorScheme = 0,
    required this.mousePos,
    this.fractalType = FractalType.mandelbulb,
  });

  FractalParams.withDefaults()
      : power = 8.0,
        iterations = 50,
        bailout = 2.0,
        zoom = 1.0,
        rotation = Vector3(0.0, 0.0, 0.0),
        colorScheme = 0,
        mousePos = Vector2(0.0, 0.0),
        fractalType = FractalType.mandelbulb;

  FractalParams copyWith({
    double? power,
    int? iterations,
    double? bailout,
    double? zoom,
    Vector3? rotation,
    int? colorScheme,
    Vector2? mousePos,
    FractalType? fractalType,
  }) {
    return FractalParams(
      power: power ?? this.power,
      iterations: iterations ?? this.iterations,
      bailout: bailout ?? this.bailout,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      colorScheme: colorScheme ?? this.colorScheme,
      mousePos: mousePos ?? this.mousePos,
      fractalType: fractalType ?? this.fractalType,
    );
  }

  @override
  List<Object?> get props => [
        power,
        iterations,
        bailout,
        zoom,
        rotation,
        colorScheme,
        mousePos,
        fractalType,
      ];
}


enum AppColorScheme {
  fire,
  ocean,
  psychedelic,
  grayscale;
}

enum FractalType {
  mandelbulb,
  mandelbox,
  julia,
  sierpinski;
}