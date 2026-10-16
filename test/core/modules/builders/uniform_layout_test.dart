import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('builder uniform layouts', () {
    test('escape-time slots expose the shader contract without gaps', () {
      expect(EscapeTimeUniformSlots.time, 0);
      expect(EscapeTimeUniformSlots.resolutionX, 1);
      expect(EscapeTimeUniformSlots.resolutionY, 2);
      expect(EscapeTimeUniformSlots.centerX, 3);
      expect(EscapeTimeUniformSlots.centerY, 4);
      expect(EscapeTimeUniformSlots.zoom, 5);
      expect(EscapeTimeUniformSlots.iterations, 6);
      expect(EscapeTimeUniformSlots.bailout, 7);
      expect(EscapeTimeUniformSlots.colorScheme, 8);
      expect(EscapeTimeUniformSlots.transparentBackground, 9);
      expect(EscapeTimeUniformSlots.extraStart, 10);
    });

    test('raymarched 3D slots expose the shader contract without gaps', () {
      expect(Raymarched3DUniformSlots.time, 0);
      expect(Raymarched3DUniformSlots.resolutionX, 1);
      expect(Raymarched3DUniformSlots.resolutionY, 2);
      expect(Raymarched3DUniformSlots.panX, 3);
      expect(Raymarched3DUniformSlots.panY, 4);
      expect(Raymarched3DUniformSlots.zoom, 5);
      expect(Raymarched3DUniformSlots.rotationX, 6);
      expect(Raymarched3DUniformSlots.rotationY, 7);
      expect(Raymarched3DUniformSlots.rotationZ, 8);
      expect(Raymarched3DUniformSlots.power, 9);
      expect(Raymarched3DUniformSlots.iterations, 10);
      expect(Raymarched3DUniformSlots.steps, 11);
      expect(Raymarched3DUniformSlots.bailout, 12);
      expect(Raymarched3DUniformSlots.colorScheme, 13);
      expect(Raymarched3DUniformSlots.fractalType, 14);
      expect(Raymarched3DUniformSlots.transparentBackground, 15);
    });

    test('raymarched 3D parameter writer binds shared scalar slots', () {
      final values = <int, double>{};
      setRaymarched3DParameterUniforms(
        setFloat: (slot, value) => values[slot] = value,
        power: 8.5,
        iterations: 42.0,
        steps: 111.0,
        bailout: 3.5,
        colorScheme: 2.0,
        fractalType: 1.0,
        transparentBackground: true,
      );

      expect(values, {
        9: 8.5,
        10: 42.0,
        11: 111.0,
        12: 3.5,
        13: 2.0,
        14: 1.0,
        15: 1.0,
      });

      setRaymarched3DParameterUniforms(
        setFloat: (slot, value) => values[slot] = value,
        power: 8.5,
        iterations: 42.0,
        steps: 111.0,
        bailout: 3.5,
        colorScheme: 2.0,
        fractalType: 1.0,
        transparentBackground: false,
      );
      expect(values[Raymarched3DUniformSlots.transparentBackground], 0.0);
    });

    test('raymarched 3D extra parameter writer binds contiguous slots safely',
        () {
      final values = <int, double>{};
      setRaymarched3DExtraParamUniforms(
        setFloat: (slot, value) => values[slot] = value,
        parameters: [
          FractalParameter(
            id: 'seed',
            label: (_) => 'Random Seed',
            type: FractalParamType.integer,
            min: 0,
            max: 9999,
            step: 1,
            defaultValue: 37,
          ),
          FractalParameter(
            id: 'roughness',
            label: (_) => 'Roughness',
            type: FractalParamType.float,
            min: 0.1,
            max: 2.0,
            step: 0.1,
            defaultValue: 0.5,
          ),
        ],
        values: <String, Object>{'seed': 10001, 'roughness': double.nan},
      );

      expect(values, {16: 9999.0, 17: 0.5});
    });

    test('raymarched 3D common writer binds camera state to shared slots', () {
      final values = <int, double>{};
      setRaymarched3DFrameUniforms(
        setFloat: (slot, value) => values[slot] = value,
        time: 12.0,
        width: 640.0,
        height: 360.0,
        view: FractalViewState(
          pan: Vector2(1.25, -0.75),
          zoom: 2.5,
          rotation: Vector3(0.1, 0.2, -0.3),
        ),
      );

      expect(values, {
        0: 12.0,
        1: 640.0,
        2: 360.0,
        3: 1.25,
        4: -0.75,
        5: 2.5,
        6: 0.1,
        7: 0.2,
        8: -0.3,
      });
    });
  });
}
